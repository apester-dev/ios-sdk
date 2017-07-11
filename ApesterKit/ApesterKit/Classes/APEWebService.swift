//
//  APEWebService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 15/06/2017.
//  Copyright © 2017 Dev Team. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import AdSupport


public struct APEWebService {
  
  public static func send(_ webView: Any, appBundleIdentifier bundleIdentifier: String?, completionHandler: ((Any?, Error?) -> Void)?)  {
    // input payload
    var inputPayload: [String: Any] = [:]
    
    // get the device advertisingIdentifier
    if let identifierManager = ASIdentifierManager.shared(), let idfa = identifierManager.advertisingIdentifier {
      inputPayload["advertisingId"] = idfa.uuidString
      inputPayload["isAdvertisingTrackingEnabled"] = identifierManager.isAdvertisingTrackingEnabled
    }
    
    // get the app bundleIdentifier
    if let bundleIdentifier = bundleIdentifier {
      inputPayload["bundleId"] = bundleIdentifier
    }
    
    // Serialize the Swift object into Data
    let serializedData = try! JSONSerialization.data(withJSONObject: inputPayload, options: [])
    
    // Encode the data into JSON string
    let encodedData = String(data: serializedData, encoding: String.Encoding.utf8)
    
    // javascript function to call
    let javaScriptString = "getAdTrackingInfo('\(encodedData!)')"
    
    // Now pass this dictionary to javascript function (Assuming it exists in the HTML code)
    if let webView = webView as? UIWebView { // use stringByEvaluatingJavaScript in case of you are using UIWebView
      let _ = webView.stringByEvaluatingJavaScript(from: javaScriptString)
      completionHandler?(true, nil)
      
    } else if let webView = webView as? WKWebView { // use stringByEvaluatingJavaScript(_: completionHandler) in case of you are using WKWebView
      webView.evaluateJavaScript(javaScriptString){ (any, error) in
        completionHandler?(any, error)
      }
    }
  }}
