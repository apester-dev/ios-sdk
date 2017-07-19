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
    case advertisingId, trackingEnabled, bundleId
  }
  
  static let setupFunctionName = "initAdvertisingParams"
  static let bundleName = "ApesterKit.bundle"
  static let fileName = "js.text"
}


/// APEWebViewService provides a light-weight framework that loads Apester Unit in a webView
public class APEWebViewService: NSObject {
  
  fileprivate var bundleIdentifier: String?
  fileprivate var webView: APEWebViewProtocol?
  fileprivate var didRunScript = false
  
  fileprivate var initialJStString: String? {
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
    
    return nil
  }
  
  fileprivate var runJSString: String {
    
    // input payload
    var inputPayload: [String: Any] = [:]
    
    // get the device advertisingIdentifier
    if let identifierManager = ASIdentifierManager.shared(), let idfa = identifierManager.advertisingIdentifier {
      inputPayload[APEConfig.Payload.advertisingId.rawValue] = idfa.uuidString
      inputPayload[APEConfig.Payload.trackingEnabled.rawValue] = identifierManager.isAdvertisingTrackingEnabled
    }
    // get the app bundleIdentifier
    if let bundleIdentifier = self.bundleIdentifier {
      inputPayload[APEConfig.Payload.bundleId.rawValue] = bundleIdentifier
    }
    // Serialize the Swift object into Data
    let serializedData = try! JSONSerialization.data(withJSONObject: inputPayload, options: [])
    // Encode the data into JSON string
    let encodedData = String(data: serializedData, encoding: String.Encoding.utf8)
    
    return "\(APEConfig.setupFunctionName)('\(encodedData!)')"
  }
  
  /// APEWebViewService shared instance
  public static let shared = APEWebViewService()
  
  // MARK: - API
  
  /**
   webview can be either UIWebView or WKWebView only - call this function from viewDidLoad
   
   - Parameters:
   - webView: either UIWebview or WKWebView instance
   - completionHandler: an optional callback with APEResult response
   
   ### Usage Example: ###
   *  self is an instance of UIViewController
   
   ````
   override func viewDidLoad() {
      super.viewDidLoad()
      APEWebViewService.shared.register(with: webView)
      // your stuff here
   }
   ````
   */
  public func register(with webView: APEWebViewProtocol, completionHandler: ((APEResult<Bool>) -> Void)? = nil) {
    
    self.webView = webView
    let res = self.evaluateJavaScript(self.initialJStString)
    completionHandler?(APEResult.success(res))
  }
  
  /**
   call this function once the webview did start load - the UIWebView delegate trigger event
   
   - Parameters:
   - sender: must be a ViewController class
   - completionHandler: an optional callback with APEResult response
   ### Usage Example: ###
   *  self is an instance of UIViewController
   
   ````
   // UIWebViewDelegate -
   func webViewDidStartLoad(_ webView: UIWebView) {
      APEWebViewService.shared.webView(didStartLoad: self.classForCoder)
   }
   ````
   * or
   
   ````
   // WKNavigationDelegate -
   func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      APEWebViewService.shared.webView(didStartLoad: self.classForCoder)
   }
   ````
   */
  public func webView(didStartLoad sender: AnyClass, completionHandler: ((APEResult<Bool>) -> Void)? = nil) {
    
    guard self.webView != nil else {
      completionHandler?(APEResult.failure("must register webView"))
      return
    }
    
    guard extractBundle(from: sender) else {
      completionHandler?(APEResult.failure("invalid bundle identifier"))
      return
    }
//    var res = self.evaluateJavaScript(self.initialJStString)
     let res = self.evaluateJavaScript(self.runJSString)
    completionHandler?(APEResult.success(res))
  }
  
}

// MARK: - PRIVATE
fileprivate extension APEWebViewService {
  
  fileprivate func extractBundle(from sender: AnyClass) -> Bool {
    guard self.bundleIdentifier == nil else {
      return true
    }
    guard let bundleIdentifier = Bundle(for: sender.self).bundleIdentifier else {
      return false
    }
    self.bundleIdentifier = bundleIdentifier
    return true
  }
  
  fileprivate func evaluateJavaScript(_ javaScriptString: String? = nil) -> Bool {
    guard let javaScriptString = javaScriptString else {
      return false
    }
    
    if let webView = webView as? UIWebView {
      // invoke stringByEvaluatingJavaScript in case of you are using UIWebView
      let _ = webView.stringByEvaluatingJavaScript(from: javaScriptString)
      return true
      
    } else if let webView = webView as? WKWebView {
      // invoke stringByEvaluatingJavaScript(_: completionHandler) in case of you are using WKWebView
      webView.evaluateJavaScript(javaScriptString){ (_, _) in }
      return true
    }
    return false
  }
}
