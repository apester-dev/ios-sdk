//
//  ApeUnitWebViewDelegateV2.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import WebKit

class APEUnitWebViewDelegateV2: NSObject, WKUIDelegate, UIScrollViewDelegate {
    
    var apeUnitView: APEUnitWebViewV2!
    var enviorment: APEUnitEnvironment!
    
    public init(_ apeUnitView: APEUnitWebViewV2, _ enviorment: APEUnitEnvironment) {
        self.apeUnitView = apeUnitView
        self.enviorment = enviorment
    }
    
}

extension APEUnitWebViewDelegateV2: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if(enviorment == .local) {
            
            if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
            {
                let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential, cred)
            }
            else
            {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          // todo handle failures
       }
    
}

extension APEUnitWebViewDelegateV2: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "apesterUnitProxy" {
            if let bodyString = message.body as? String {
                guard let strongApeUnitView = self.apeUnitView else { return }
                if(bodyString.contains("apester_resize_unit")) {
                    guard let dictionary = bodyString.dictionary else {
                        return
                    }
                    
                    let height = CGFloat(dictionary["height"] as? Double ?? 0)
                    let width = CGFloat(dictionary["width"] as? Double ?? 0)
                    strongApeUnitView.updateSize(APEUnitWebViewV2.ApeUnitSize(width: width, height: height));
                    
                }
                
            }
        }
    }
}
