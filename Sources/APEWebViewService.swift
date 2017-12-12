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

private struct APEConfig {

  enum Payload: String {
    case advertisingId, trackingEnabled, bundleId, appName, appStoreUrl
  }

  static let bundleName = "ApesterKit.bundle"
  //
  static let apesterLoadCallbackFileName = "loadCallbackJS.text"
  static let initAdevrtisingParamsFunctionName = "initAdvertisingParams"
  //
  static let apesterRegisterJSFileName = "registerJS.text"
  //
  static let apesterCallbackFunction = "apesterCallback"
  static let apesterKitCallback = "apesterKitCallback"

  
}

/// APEWebViewService provides a light-weight framework that loads Apester Unit in a webView
public class APEWebViewService: NSObject {
  /// APEWebViewService shared instance
  public static let shared = APEWebViewService()

  /// the app main bundle
  fileprivate var bundle: Bundle?
  fileprivate weak var webView: APEWebViewProtocol?
  fileprivate var unitHeightHandler: APEUnitHeightHandler?

  // the converted apesterLoadCallback js file to  string
  fileprivate lazy var loadCallbackJSString: String = {
    return self.convertJavaScriptFileToString(file: APEConfig.apesterLoadCallbackFileName)
  }()
  
  // the converted apesterLoadCallback js file to  string
  fileprivate lazy var registerJSString: String = {
    return self.convertJavaScriptFileToString(file: APEConfig.apesterRegisterJSFileName)
  }()

  // the deviceInfoParamsDictionary settings data
  fileprivate lazy var deviceInfoParamsPayload: [String: Any] = {
    var deviceInfoPayload: [String: Any] = [:]
    
    // get the device advertisingIdentifier
    #if swift(>=4.0)
      let identifierManager = ASIdentifierManager.shared()
      let idfa = identifierManager.advertisingIdentifier
      deviceInfoPayload[APEConfig.Payload.advertisingId.rawValue] = idfa.uuidString
      deviceInfoPayload[APEConfig.Payload.trackingEnabled.rawValue] = identifierManager.isAdvertisingTrackingEnabled
    #else
      if let identifierManager = ASIdentifierManager.shared(),
        let idfa = identifierManager.advertisingIdentifier {
        inputPayload[APEConfig.Payload.advertisingId.rawValue] = idfa.uuidString
        inputPayload[APEConfig.Payload.trackingEnabled.rawValue] = identifierManager.isAdvertisingTrackingEnabled
      }
    #endif
    
    if let bundle = self.bundle {
      // get the app bundleIdentifier
      if let bundleIdentifier = bundle.bundleIdentifier {
        deviceInfoPayload[APEConfig.Payload.bundleId.rawValue] = bundleIdentifier
      }
      // get the app name and
      if let infoDictionary = bundle.infoDictionary,
        let appName = infoDictionary[kCFBundleNameKey as String] as? String {
        deviceInfoPayload[APEConfig.Payload.appName.rawValue] = appName
        deviceInfoPayload[APEConfig.Payload.appStoreUrl.rawValue] = "https://appstore.com/\(appName.trimmingCharacters(in: .whitespaces))"
      }
    }
    return deviceInfoPayload
  }()

  fileprivate func convertJavaScriptFileToString(file: String) -> String {
    // load js bundle file
    let klass: AnyClass = object_getClass(self)!
    if let bundleResourcePath = Bundle(for: klass).resourcePath {
      let path = "\(bundleResourcePath)/\(APEConfig.bundleName)/\(file)"
      let data = NSData(contentsOfFile: path)
      if let fileData = data as Data? {
        if let result = String(data: fileData, encoding: String.Encoding.utf8) {
          return result
        }
      }
    }
    return ""
  }
  
  // the function with payload params string
  fileprivate var adevrtisingParamsJSFunctionString: String? {
    // Serialize the Swift object into Data
    if let serializedData = try? JSONSerialization.data(withJSONObject: deviceInfoParamsPayload, options: []) ,
      // Encode the data into JSON string
      let encodedData = String(data: serializedData, encoding: String.Encoding.utf8) {
      return "\(APEConfig.initAdevrtisingParamsFunctionName)('\(encodedData)')"
    }
    return nil
  }

  // evaluateJavaScript on UIWebView or WKWebView
  fileprivate func evaluateJavaScript(_ javaScriptString: String? = nil) -> String? {
    guard let javaScriptString = javaScriptString else {
      return nil
    }
    
    if let webView = self.webView as? UIWebView {
      // invoke stringByEvaluatingJavaScript in case of you are using UIWebView
      return webView.stringByEvaluatingJavaScript(from: javaScriptString)
      
    } else if let webView = self.webView as? WKWebView {
      // invoke stringByEvaluatingJavaScript(_: completionHandler) in case of you are using WKWebView
      webView.evaluateJavaScript(javaScriptString) { (_, _) in }
      return ""
    }
    return nil
  }
}

// MARK: - WKScriptMessageHandler
extension APEWebViewService: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    // This takes a while, but eventually we'll the proper height here.
    guard let number = message.body as? NSNumber else { return }
    unitHeightHandler?(APEResult.success(CGFloat(truncating: number) + 15))
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
                       unitHeightHandler: APEUnitHeightHandler? = nil,
                       completionHandler: APEResultHandler? = nil) {
    self.bundle = bundle
    self.webView = webView
    self.unitHeightHandler = unitHeightHandler

    if let webview = webView as? WKWebView {
      // Load the script to be inserted into the template
      let validationScript = WKUserScript(source: registerJSString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
      
      // Create a config and add the listener and the custom script
      let config = webview.configuration
      config.userContentController.add(self, name: APEConfig.apesterCallbackFunction)
      config.userContentController.addUserScript(validationScript)
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

    // declaration of loadCallbackJS (initAdevrtisingParams function)
    var res = self.evaluateJavaScript(self.loadCallbackJSString)
    
    // call initAdevrtisingParams function with the device params info
    res = self.evaluateJavaScript(self.adevrtisingParamsJSFunctionString)
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
    if webView is UIWebView {
      _ = self.evaluateJavaScript(self.registerJSString)

      if let value = self.evaluateJavaScript("window.\(APEConfig.apesterKitCallback)"),
        let number = NumberFormatter().number(from: value) {
        unitHeightHandler?(APEResult.success(CGFloat(truncating: number) + 15))
      }
    }
  }


  
}
