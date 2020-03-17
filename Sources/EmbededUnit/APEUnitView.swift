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
    private var containerView: UIView?
    private weak var containerViewConroller: UIViewController?
    private var configuration: APEUnitConfiguration!
    public weak var delegate: APEUnitViewDelegate?

    private var messageDispatcher = MessageDispatcher()
    
    /// The view visibility status, update this property either when the view is visible or not.
    public var isDisplayed: Bool = false {
        didSet {
            self.messageDispatcher
                .dispatchAsync(Constants.Unit.setViewVisibilityStatus(isDisplayed),
                               to: self.unitWebView)
        }
    }
    
    public init(configuration: APEUnitConfiguration) {
        super.init()
        
        self.configuration = configuration
        let options = WKWebView.Options(events: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibity], contentBehavior: .never, delegate: self)
        
        self.unitWebView = WKWebView.make(with: options)
        
        if let unitUrl = configuration.unitURL {
            unitWebView.load(URLRequest(url: unitUrl))
        }
        
    }
    
     public func display(in containerView: UIView, containerViewConroller: UIViewController) {
     
        // update unitWebView frame according to containerView bounds
        containerView.layoutIfNeeded()
        containerView.addSubview(self.unitWebView)
        unitWebView.anchor(top: containerView.topAnchor, paddingTop: 0, bottom: containerView.bottomAnchor, paddingBottom: 0, leadingAnchor: containerView.leadingAnchor, paddingLeading: 0, trailingAnchor: containerView.trailingAnchor, paddingTrailing: 0, width: nil, height: nil)
    
        self.containerView = containerView
        self.containerViewConroller = containerViewConroller
        
    }
    
    func destroy() {
        self.unitWebView.configuration.userContentController
            .unregister(from: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibity])
    }
    
    /// Remove the unit web view
    public func hide() {
        self.unitWebView.removeFromSuperview()
    }
    
    func open(url: URL, type: APEUnitViewNavigationType) {
        let open: ((URL) -> Void) = { url in
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { _ in }
                }
            }
        }
        
        // wait for shouldHandleURL callback
        let shouldHandleURL: Void? = self.delegate?.unitView?(self, shouldHandleURL: url, type: type) {
            if !$0 {
                open(url)
            }
        }
        // check if the shouldHandleURL is implemented
        if shouldHandleURL == nil {
            open(url)
        }
    }

    func decisionHandler(navigationAction: WKNavigationAction, webView: WKWebView, completion: (WKNavigationActionPolicy) -> Void) {
        var policy = WKNavigationActionPolicy.cancel
        // is valid URL
        if let url = navigationAction.request.url {
            switch navigationAction.navigationType {
            case .other:
                // redirect when the target is a main frame
                if let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame,
                    url.absoluteString != webView.url?.absoluteString {
                    open(url: url, type: .other)
                } else {
                    policy = .allow // allow webview requests communication
                }
            case .linkActivated:
                // redirect when the main web view link got clickd.
                if let scheme = url.scheme, scheme.contains("http") {
                    open(url: url, type: .linkActivated)
                }
            default: break
            }
        }
        completion(policy)
    }
    
    deinit {
        hide()
        destroy()
    }
    
}

extension APEUnitView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if case .local = self.configuration.environment,
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.destroy()
        self.delegate?.unitView(self, didFailLoadingUnit: self.configuration.unitParams.id)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.unitWebView.appendAppNameToUserAgent(self.configuration.bundleInfo)
        self.delegate?.unitView(self, didFinishLoadingUnit: self.configuration.unitParams.id)
    }

    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                        preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode = .mobile
        self.decisionHandler(navigationAction: navigationAction, webView: webView) { policy in
            decisionHandler(policy, preferences)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.decisionHandler(navigationAction: navigationAction, webView: webView, completion: decisionHandler)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse,
            let url = navigationResponse.response.url else {
                decisionHandler(.cancel)
                return
        }
        if let headerFields = response.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { cookie in
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
        decisionHandler(.allow)
    }
    
}

// MARK:- WKUIDelegate
@available(iOS 11.0, *)
extension APEUnitView: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            self.open(url: url, type: .shareLinkActivated)
        }
        return nil
    }
    
}

private extension APEUnitView {
    
    func setContainerViewSize(anchor: NSLayoutDimension, attribute: NSLayoutConstraint.Attribute, size: CGFloat) {
        
        self.containerView?.constraints
            .first(where: { $0.firstAttribute == attribute })
            .flatMap { NSLayoutConstraint.deactivate([$0]) }
        
        let containerViewConstraint = anchor.constraint(equalToConstant: size)
        containerViewConstraint.priority = .defaultHigh
        containerViewConstraint.isActive = true
        
    }
    
    func update(size: CGSize) {
        
        let unitWebViewHeightConstraint = unitWebView.heightAnchor.constraint(equalToConstant: size.height)
        unitWebViewHeightConstraint.isActive = false
        unitWebViewHeightConstraint.priority = .defaultHigh
        unitWebViewHeightConstraint.isActive = true
        
        // height
        if let heightAnchor = self.containerView?.heightAnchor {
            self.setContainerViewSize(anchor: heightAnchor, attribute: .height, size: size.height)
        }
        
        //width
        if let widthAnchor = self.containerView?.widthAnchor {
            self.setContainerViewSize(anchor: widthAnchor, attribute: .width, size: size.width)
        }
        
    }
    
}

extension APEUnitView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageName = message.name
        
        if message.webView?.hash == self.unitWebView.hash,
            messageName == Constants.Unit.proxy,
            let bodyString = message.body as? String {

            if bodyString.contains(Constants.Unit.resize),
                let dictionary = bodyString.dictionary {
                let height = dictionary.floatValue(for: Constants.Unit.height)
                let width = dictionary.floatValue(for: Constants.Unit.width)
                self.update(size: CGSize(width: width, height: height));
            }

        }
        
        if messageName == Constants.Unit.validateUnitViewVisibity {
            guard let containerVC = self.containerViewConroller, let view = self.containerView else {
                self.isDisplayed = false
                return
            }
            if containerVC.view.allSubviews.first(where: { $0 == view }) != nil {
                let convertedCenterPoint = view.convert(view.center, to: containerVC.view)
                self.isDisplayed = containerVC.view.bounds.contains(convertedCenterPoint)
            } else {
                self.isDisplayed = false
            }
        }
    }
}

extension APEUnitView: UIScrollViewDelegate {}

private extension Dictionary {
    func floatValue(for key: Key) -> CGFloat {
        CGFloat(self[key] as? Double ?? 0)
    }
}
