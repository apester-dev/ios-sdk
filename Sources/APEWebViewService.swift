//
//  APEWebViewService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 12/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import AdSupport

/// APEWebViewService provides a light-weight framework that loads Apester Unit in a webView
public class APEWebViewService: NSObject {
  /// APEWebViewService shared instance
  public static let shared = APEWebViewService()

  /// the app main bundle
  fileprivate var bundle: Bundle?
  fileprivate var unitHeightHandlers: [Int: APEUnitHeightHandler] = [:]
  fileprivate var unitsLoadedSet = Set<Int>()

  // the converted apesterLoadCallback js file to  string
  fileprivate lazy var loadCallbackJSString: String = {
    return APEBundle.contentsOfFile(APEConfig.WebView.loadCallbackFileName)
  }()
  
  // the converted apesterLoadCallback js file to  string
  fileprivate lazy var registerJSString: String = {
    return APEBundle.contentsOfFile(APEConfig.WebView.registerJSFileName)
  }()

  // the deviceInfoParamsDictionary settings data
  fileprivate lazy var deviceInfoParamsPayload: [String: Any] = {
    var deviceInfoPayload: [String: Any] = [:]
    
    // get the device advertisingIdentifier
    let identifierManager = ASIdentifierManager.shared()
    let idfa = identifierManager.advertisingIdentifier
    deviceInfoPayload[APEConfig.Payload.advertisingId] = idfa.uuidString
    deviceInfoPayload[APEConfig.Payload.trackingEnabled] = identifierManager.isAdvertisingTrackingEnabled
    
    if let bundle = self.bundle {
      // get the app bundleIdentifier
      if let bundleIdentifier = bundle.bundleIdentifier {
        deviceInfoPayload[APEConfig.Payload.bundleId] = bundleIdentifier
      }
      // get the app name and
      if let infoDictionary = bundle.infoDictionary,
        let appName = infoDictionary[kCFBundleNameKey as String] as? String {
        deviceInfoPayload[APEConfig.Payload.appName] = appName
        deviceInfoPayload[APEConfig.Payload.appStoreUrl] = "https://appstore.com/\(appName.trimmingCharacters(in: .whitespaces))"
      }
    }
    return deviceInfoPayload
  }()
  
  // the function with payload params string
  fileprivate var adevrtisingParamsJSFunctionString: String? {
    // Serialize the Swift object into Data
    if let serializedData = try? JSONSerialization.data(withJSONObject: deviceInfoParamsPayload, options: []) ,
      // Encode the data into JSON string
      let encodedData = String(data: serializedData, encoding: String.Encoding.utf8) {
      return "\(APEConfig.WebView.initAdevrtisingParamsFunctionName)('\(encodedData)')"
    }
    return nil
  }

  // evaluateJavaScript on UIWebView or WKWebView
  fileprivate func evaluateJavaScript(_ javaScriptString: String? = nil, webView: APEWebViewProtocol) -> String? {
    guard let javaScriptString = javaScriptString else {
      return nil
    }

    if let webView = webView as? UIWebView {
      // invoke stringByEvaluatingJavaScript in case of you are using UIWebView
      return webView.stringByEvaluatingJavaScript(from: javaScriptString)

    } else if let webView = webView as? WKWebView {
      // invoke stringByEvaluatingJavaScript(_: completionHandler) in case of you are using WKWebView
      webView.evaluateJavaScript(javaScriptString) { (_, _) in }
    }

    return ""
  }

  fileprivate func updateUIWebViewUnitHeight(for webView: UIWebView) {
    guard let handler = self.unitHeightHandlers[webView.hashValue] else {
      return 
    }
    _ = self.evaluateJavaScript(self.registerJSString, webView: webView)
    if let value = self.evaluateJavaScript("window.\(APEConfig.WebView.callback)", webView: webView),
      let number = NumberFormatter().number(from: value) {
        handler(APEResult.success(CGFloat(truncating: number) + 15))
        self.unitHeightHandlers[webView.hashValue] = nil
    }
  }
}

// MARK: - WKScriptMessageHandler
extension APEWebViewService: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let handler = self.unitHeightHandlers[userContentController.hashValue] else {
      return
    }
    // This takes a while, but eventually we'll the proper height here.
    guard let number = message.body as? NSNumber else { return }
    handler(APEResult.success(CGFloat(truncating: number) + 15))
    self.unitHeightHandlers[userContentController.hashValue] = nil
  }
}


// MARK: - Interface
public extension APEWebViewService {

  typealias APEResultHandler = ((APEResult<Bool>) -> Void)
  typealias APEUnitHeightHandler = ((APEResult<CGFloat>) -> Void)

  /**
   call register(bundle:webview:unitHeightHandler:completionHandler:) function from viewDidLoad
   
   - Parameters:
      - bundle: the app main bundle
      - webview: the viewcontroller webview subview
      - unitHeightHandler: an optional callback with APEResult response of the apester unit height
      - completionHandler: an optional callback with APEResult response of the api success or failure
   
   ### Usage Example: ###
   
   ````
   override func viewDidLoad() {
   super.viewDidLoad()
   APEWebViewService.shared.register(bundle: Bundle.main, webView: webView, unitHeightHandler: { [weak self] result in
    switch result {
    case .success(let height):
      print(height)
    case .failure(let err):
      print(err)
    }
   })
   // your stuff here
   }
   ````
   */
  public func register(bundle: Bundle, webView: APEWebViewProtocol,
                       unitHeightHandler: APEUnitHeightHandler? = nil, completionHandler: APEResultHandler? = nil) {
    self.bundle = bundle

    if let webview = webView as? WKWebView {

      // Create a config and add the listener and the custom script
      let config = webview.configuration

      // Load the script to be inserted into the template
      let script = WKUserScript(source: registerJSString, injectionTime: .atDocumentStart, forMainFrameOnly: true)

      config.userContentController.removeScriptMessageHandler(forName: APEConfig.WebView.callbackFunction)
      config.userContentController.add(self, name: APEConfig.WebView.callbackFunction)
      config.userContentController.addUserScript(script)

        if let unitHeightHandler = unitHeightHandler {
          self.unitHeightHandlers[config.userContentController.hashValue] = unitHeightHandler
        }
    } else if let webview = webView as? UIWebView,
      let unitHeightHandler = unitHeightHandler {
        self.unitHeightHandlers[webview.hashValue] = unitHeightHandler
    }

    completionHandler?(APEResult.success(self.bundle != nil))
  }
  
  /**
   call didStartLoad(webView:) function once the webview delegate didStartLoad triggered,
   then APEWebViewService will evaluateJavaScript on the webview with extracting params from the app bundle.
   
   - Parameters:
      - webView: must be an instance of UIWebView Or WKWebview
      - completionHandler: an optional callback with APEResult response
   
   ### Usage Example: ###
   
   ````
   // UIWebViewDelegate -
   func webViewDidStartLoad(_ webView: UIWebView) {
   APEWebViewService.shared.didStartLoad(webView: webView)
   }
   ````
   * or
   
   ````
   // WKNavigationDelegate -
   func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
   APEWebViewService.shared.didStartLoad(webView: webView)
   }
   ````
   */
  public func didStartLoad(webView: APEWebViewProtocol, completionHandler: APEResultHandler? = nil) {
    if let webview = webView as? WKWebView {
      guard !unitsLoadedSet.contains(webview.configuration.userContentController.hashValue) else {
        return
      }
      unitsLoadedSet.insert(webview.configuration.userContentController.hashValue)
    } else if let webview = webView as? UIWebView {
      guard !unitsLoadedSet.contains(webview.hashValue) else {
        return
      }
      unitsLoadedSet.insert(webview.hashValue)
    }
    // declaration of loadCallbackJS (initAdevrtisingParams function)
    var res = self.evaluateJavaScript(self.loadCallbackJSString, webView: webView)
    
    // call initAdevrtisingParams function with the device params info
    res = self.evaluateJavaScript(self.adevrtisingParamsJSFunctionString, webView: webView)
    completionHandler?(APEResult.success(res != nil))
  }

  /**
   call didFinishLoad(webView:) function once the webview delegate didFinishLoad triggered,
   then APEWebViewService will evaluateJavaScript on the webview with unit fixed height.

   - Parameters:
   - webView: must be an instance of UIWebView Or WKWebview
   - completionHandler: an optional callback with APEResult response

   ### Usage Example: ###

   ````
   // UIWebViewDelegate -

   func webViewDidFinishLoad(_ webView: UIWebView) {
   APEWebViewService.shared.didFinishLoad(webView: webView)
   }
   ````
   * or

   ````
   // WKNavigationDelegate -

   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
   APEWebViewService.shared.didFinishLoad(webView: webView)
   }
   }
   ````
   */

  public func didFinishLoad(webView: APEWebViewProtocol, completionHandler: APEResultHandler? = nil) {
    if let webview = webView as? UIWebView {
      updateUIWebViewUnitHeight(for: webview)
    }
    completionHandler?(APEResult.success(true))
  }


  
}
