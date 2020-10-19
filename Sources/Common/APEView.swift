//
//  File.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 3/19/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import WebKit
import SafariServices

#if os(iOS)
@available(iOS 11.0, *)

/// A Proxy Messaging Handler
///
/// Between The Apester Units Carousel component (The `StripWebView`)
/// And the selected Apester Unit (The `StoryWebView`)
@objcMembers public class APEView: NSObject {

    struct LoadingState {
        var isLoaded = false
        var isReady = false
        var height: CGFloat = 10
        var initialMessage: String?
        var openUnitMessage: String?
    }

    var lastDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    let setDeviceOrientation: ((Int) -> Void) = { UIDevice.current.setValue($0, forKey: "orientation") }

    var containerView: UIView?
    weak var containerViewConroller: UIViewController?

    // MARK:- Private Properties
    private let environment: APEEnvironment!

    var messageDispatcher = MessageDispatcher()

    var loadingState = LoadingState()

    var subscribedEvents: Set<String> = Set()

    // MARK:- Public Properties
    public var height: CGFloat {
        return .zero
    }

    /// The strip view visibility status, update this property either when the strip view is visible or not.
    public var isDisplayed: Bool = false


    init(_ environment: APEEnvironment) {
        self.environment = environment
        super.init()
        // prefetch channel data...
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.orientationDidChangeNotification()
        }
    }

    /// Display the channel carousel units view
    ///
    /// - Parameters:
    ///   - containerView: the channel strip view superview
    ///   - containerViewConroller: the container view ViewController
    public func display(in containerView: UIView, containerViewConroller: UIViewController) {
        self.containerView = containerView
        self.containerViewConroller = containerViewConroller
    }

    /// Remove the channel carousel units view
    public func hide() {
        fatalError("OVERRIDE ME")
    }
    
    /// Refresh strip / unit content
    public func refreshContent() {
        fatalError("OVERRIDE ME")
    }

    /// Hide the story view
    public func hideStory() {
        fatalError("OVERRIDE ME")
    }
    
    /// Reload the webView
    public func reload() {
        fatalError("OVERRIDE ME")
    }

    /// subscribe to events in order to observe the events messages data.
    /// for Example, subscribe to load and ready events by: `stripView.subscribe(["strip_loaded", "apester_strip_units"])`
    /// - Parameter events: the event names.
    public func subscribe(events: [String]) {
        DispatchQueue.main.async {
            self.subscribedEvents = self.subscribedEvents.union(events)
        }
    }

    /// unsubscribe from events.
    /// - Parameter events: the event names.
    public func unsubscribe(events: [String]) {
        DispatchQueue.main.async {
            self.subscribedEvents = self.subscribedEvents.subtracting(events)
        }
    }

    func open(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { _ in }
            }
        }
    }

    deinit {
        hide()
        destroy()
    }
}

// MARK:- Internal API's to override
@available(iOS 11.0, *)
extension APEView {

    func orientationDidChangeNotification() {
        fatalError("OVERRIDE ME")
    }

    func open(url: URL, type: APEViewNavigationType) {
        fatalError("OVERRIDE ME")
    }

    func didFailLoading(error: Error) {
        fatalError("OVERRIDE ME")
    }

    func didFinishLoading() {
        fatalError("OVERRIDE ME")
    }

    func handleUserContentController(message: WKScriptMessage) {
        fatalError("OVERRIDE ME")
    }

    func destroy() {
        fatalError("OVERRIDE ME")
    }
}

// MARK:- Handle WebView Presentation
@available(iOS 11.0, * )
private extension APEView {
    func decisionHandler(navigationAction: WKNavigationAction, webView: WKWebView, completion: (WKNavigationActionPolicy) -> Void) {
        var policy = WKNavigationActionPolicy.cancel
        // is valid URL
        if let url = navigationAction.request.url {
            switch navigationAction.navigationType {
                case .other:
                    // redirect when the target is a main frame and the strip has been loaded.
                    if loadingState.isLoaded, let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame,
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
}

// MARK: UIAdaptivePresentationControllerDelegate
@available(iOS 11.0, *)
extension APEView: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.hideStory()
    }
}

// MARK:- WKScriptMessageHandler
@available(iOS 11.0, *)
extension APEView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.main.async {
            self.handleUserContentController(message: message)
        }
    }
}

// MARK:- WKNavigationDelegate
@available(iOS 11.0, *)
extension APEView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if case .local = self.environment,
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
        self.loadingState.isLoaded = false
        self.didFailLoading(error: error)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.didFinishLoading()
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
extension APEView: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            self.open(url: url, type: .shareLinkActivated)
        }
        return nil
    }
}

// MARK:- WKScriptMessageHandler
@available(iOS 11.0, *)
extension APEView: UIScrollViewDelegate {
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
#endif
