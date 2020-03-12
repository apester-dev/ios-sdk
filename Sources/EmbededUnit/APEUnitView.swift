//
//  APEUnitWebView.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import WebKit

@objcMembers public class APEUnitView: NSObject {
    
    public private(set) var unitWebView: WKWebView!    
    private var enviorement: APEUnitEnvironment!
    
    public init(configuration: APEUnitConfiguration) {
        super.init()
        self.enviorement = configuration.environment
        
        let options = WKWebView.Options(events: [Constants.Unit.proxy], contentBehavior: .never, delegate: self)

        self.unitWebView = WKWebView.make(with: options)
        
        if let unitUrl = configuration.unitURL {
            unitWebView.load(URLRequest(url: unitUrl))
        }
    }
    
    public func update(size: CGSize) {
        self.unitWebView.translatesAutoresizingMaskIntoConstraints = false
        let containerViewHeightConstraint = unitWebView.heightAnchor.constraint(equalToConstant: size.height)
        containerViewHeightConstraint.priority = .defaultHigh
        containerViewHeightConstraint.isActive = true
        
        let width = min(size.width, UIScreen.main.bounds.size.width)
        let containerViewWidthConstraint = unitWebView.widthAnchor.constraint(equalToConstant: width)
        
        containerViewWidthConstraint.priority = .defaultHigh
        containerViewWidthConstraint.isActive = true
        
        if let safeSuperview = unitWebView.superview {
            unitWebView.topAnchor.constraint(equalTo: safeSuperview.topAnchor).isActive = true
            unitWebView.centerXAnchor.constraint(equalTo: safeSuperview.centerXAnchor).isActive = true
        }
    }
}

extension APEUnitView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if case .local = self.enviorement,
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }
    
    // todo handle failures
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
}

extension APEUnitView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.Unit.proxy,
            let bodyString = message.body as? String,
            bodyString.contains(Constants.Unit.resize),
            let dictionary = bodyString.dictionary {

            let height = dictionary.floatValue(for: Constants.Unit.height)
            let width = dictionary.floatValue(for: Constants.Unit.width)
            self.update(size: CGSize(width: width, height: height));
        }
    }
}

extension APEUnitView: WKUIDelegate {}

extension APEUnitView: UIScrollViewDelegate {}

private extension Dictionary {
    func floatValue(for key: Key) -> CGFloat {
        CGFloat(self[key] as? Double ?? 0)
    }
}
