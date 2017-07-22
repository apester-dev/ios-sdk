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

  static let setupFunctionName = "initAdvertisingParams"
  static let bundleName = "ApesterKit.bundle"
  static let fileName = "js.text"
}

/// APEWebViewService provides a light-weight framework that loads Apester Unit in a webView
public class APEWebViewService: NSObject {

  fileprivate var bundle: Bundle?

  fileprivate lazy var initialJStString: String = {
    // load js bundle file
    let klass: AnyClass = object_getClass(self)!
    if let bundleResourcePath = Bundle(for: klass).resourcePath {
      let path = "\(bundleResourcePath)/\(APEConfig.bundleName)/\(APEConfig.fileName)"
      let data = NSData(contentsOfFile: path)
      if let fileData = data as Data? {
        if let result = String(data: fileData, encoding: String.Encoding.utf8) {
          return result
        }
      }
    }
    return ""
  }()

  fileprivate lazy var inputPayload: [String: Any] = {
    var inputPayload: [String: Any] = [:]
    // get the device advertisingIdentifier
    if let identifierManager = ASIdentifierManager.shared(),
      let idfa = identifierManager.advertisingIdentifier {
      inputPayload[APEConfig.Payload.advertisingId.rawValue] = idfa.uuidString
      inputPayload[APEConfig.Payload.trackingEnabled.rawValue] = identifierManager.isAdvertisingTrackingEnabled
    }
    if let bundle = self.bundle {
      // get the app bundleIdentifier
      if let bundleIdentifier = bundle.bundleIdentifier {
        inputPayload[APEConfig.Payload.bundleId.rawValue] = bundleIdentifier
      }
      // get the app name and
      if let infoDictionary = bundle.infoDictionary,
        let appName = infoDictionary[kCFBundleNameKey as String] as? String {
        inputPayload[APEConfig.Payload.appName.rawValue] = appName
        inputPayload[APEConfig.Payload.appStoreUrl.rawValue] = "https://appstore.com/\(appName.trimmingCharacters(in: .whitespaces))"
      }
    }
    return inputPayload
  }()

  fileprivate var runJSString: String? {
    // Serialize the Swift object into Data
    if let serializedData = try? JSONSerialization.data(withJSONObject: inputPayload, options: []) ,
      // Encode the data into JSON string
      let encodedData = String(data: serializedData, encoding: String.Encoding.utf8) {
      return "\(APEConfig.setupFunctionName)('\(encodedData)')"
    }
    return nil
  }

  /// APEWebViewService shared instance
  public static let shared = APEWebViewService()

  // MARK: - API

  /**
   call register(bundle:) function from viewDidLoad
   
    Parameters:
    - bundle: the app main bundle
    - completionHandler: an optional callback with APEResult response
   
   ### Usage Example: ###
   
   ````
   override func viewDidLoad() {
      super.viewDidLoad()
      APEWebViewService.shared.register(bundle: Bundle.main)
      // your stuff here
   }
   ````
   */
  public func register(bundle: Bundle, completionHandler: ((APEResult<Bool>) -> Void)? = nil) {
    self.bundle = bundle
    completionHandler?(APEResult.success(self.bundle != nil))
  }

  /**
   call webViewDidStartLoad function once the webview delegate did start load get called, 
   then APEWebViewService will evaluateJavaScript on the webview by extracting params from the app bundle.
   
   Parameters:
   - webView: must be an instance of UIWebView Or WKWebview
   - completionHandler: an optional callback with APEResult response
   
   ### Usage Example: ###
   
   ````
   // UIWebViewDelegate -
   func webViewDidStartLoad(_ webView: UIWebView) {
      APEWebViewService.shared.webViewDidStartLoad(webView: webView)
   }
   ````
   * or
   
   ````
   // WKNavigationDelegate -
   func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      APEWebViewService.shared.webViewDidStartLoad(webView: webView)
   }
   ````
   */
  public func webViewDidStartLoad(webView: APEWebViewProtocol, completionHandler: ((APEResult<Bool>) -> Void)? = nil) {
    var res = self.evaluateJavaScript(self.initialJStString, on: webView)
    res = self.evaluateJavaScript(self.runJSString, on: webView)
    completionHandler?(APEResult.success(res))
  }

}

// MARK: - PRIVATE
fileprivate extension APEWebViewService {

  fileprivate func evaluateJavaScript(_ javaScriptString: String? = nil, on webView: APEWebViewProtocol) -> Bool {
    guard let javaScriptString = javaScriptString else {
      return false
    }

    if let webView = webView as? UIWebView {
      // invoke stringByEvaluatingJavaScript in case of you are using UIWebView
      _ = webView.stringByEvaluatingJavaScript(from: javaScriptString)
      return true

    } else if let webView = webView as? WKWebView {
      // invoke stringByEvaluatingJavaScript(_: completionHandler) in case of you are using WKWebView
      webView.evaluateJavaScript(javaScriptString) { (_, _) in }
      return true
    }
    return false
  }
}
