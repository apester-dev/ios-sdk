//
//  APEUnitWebView.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import WebKit

@objcMembers public class APEUnitView: NSObject, UIScrollViewDelegate, WKUIDelegate {
    
    public private(set) var unitWebView: WKWebView!
    public private(set) var apeUnitEnviorement: APEUnitEnvironment!
    
    public init(_ configuration: APEUnitConfiguration) {
        super.init()
        
        apeUnitEnviorement = configuration.environment
        
        let options = WKWebView.Options(events: [Constants.Unit.proxy],
                                        contentBehavior: .never,
                                        delegate: self)

        self.unitWebView = WKWebView.make(with: options)
        
        guard let unitUrl = configuration.unitURL else { return }
        
        unitWebView.load(URLRequest(url: unitUrl))
    }
    
    public func update(_ size: CGSize) {
        
        self.unitWebView.translatesAutoresizingMaskIntoConstraints = false
        let containerViewHeightConstraint = unitWebView.heightAnchor.constraint(equalToConstant: size.height)
        containerViewHeightConstraint.priority = .defaultHigh
        containerViewHeightConstraint.isActive = true
        
        let width = min(size.width, UIScreen.main.bounds.size.width)
        let containerViewWidthConstraint = unitWebView.widthAnchor.constraint(equalToConstant: width)
        
        containerViewWidthConstraint.priority = .defaultHigh
        containerViewWidthConstraint.isActive = true
        
        guard let safeSuperview = unitWebView.superview else {
            return
        }
        
        unitWebView.topAnchor.constraint(equalTo: safeSuperview.topAnchor).isActive = true
        
        unitWebView.centerXAnchor.constraint(equalTo: safeSuperview.centerXAnchor).isActive = true
        
    }
}

extension APEUnitView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if self.apeUnitEnviorement == .local {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
            {
                let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential, cred)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          // todo handle failures
       }
    
}

extension APEUnitView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.Unit.proxy {
            if let bodyString = message.body as? String {
                if(bodyString.contains(Constants.Unit.resize)) {
                    guard let dictionary = bodyString.dictionary else {
                        return
                    }
                    let height = dictionary.floatValue(for: Constants.Unit.height)
                    let width = dictionary.floatValue(for: Constants.Unit.width)
                    self.update(CGSize(width: width, height: height));
                }
                
            }
        }
    }
}

private extension Dictionary {
    func floatValue(for key: Key) -> CGFloat {
        CGFloat(self[key] as? Double ?? 0)
    }
}


// gallery - 5d3ff466640846006e46146e
// quiz 5d6527a40f10dd006186dbcd
//story 5ddeaa945d06ef005f3668e8
// like quiz 5d6523720f10dd006186dbc9
