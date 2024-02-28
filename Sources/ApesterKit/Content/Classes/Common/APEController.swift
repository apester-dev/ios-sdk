//
//  APEController.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 3/19/20.
//  Copyright © 2020 Apester. All rights reserved.
//
import Foundation
import WebKit
import SafariServices
///
///
///
#if os(iOS)
@available(iOS 11.0, *)
///
///
///
public typealias APEView = APEController
/// A Proxy Messaging Handler
///
/// Between The Apester Units Carousel component (The `StripWebView`)
/// And the selected Apester Unit                (The `StoryWebView`)
@objc(APEView)
@objcMembers
public class APEController : NSObject
{
    internal struct LoadingState
    {
        internal var isLoaded       : Bool    = false
        internal var isReady        : Bool    = false
        internal var height         : CGFloat = 10
        internal var  initialMessage: String?
        internal var openUnitMessage: String?
    }
    
    internal var lastDeviceOrientation: UIDeviceOrientation
    internal let setDeviceOrientation : ((Int) -> Void)     = {
        UIDevice.current.setValue($0, forKey: "orientation")
    }

    internal var containerView: UIView?
    internal weak var containerViewController: UIViewController?

    // MARK:- Private Properties
    
    internal var messageDispatcher : MessageDispatcher

    internal var loadingState : LoadingState

    internal var subscribedEvents: Set<String>

    // MARK:- Public Properties
    public var height: CGFloat {
        return .zero
    }

    /// The strip view visibility status, update this property either when the strip view is visible or not.
    public var isDisplayed : Bool

    override init()
    {
        self.lastDeviceOrientation = UIDevice.current.orientation
        self.messageDispatcher     = MessageDispatcher()
        self.loadingState          = LoadingState()
        self.subscribedEvents      = Set()
        self.isDisplayed           = false
        super.init()
        
        // prefetch channel data...
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            strongSelf.orientationDidChangeNotification()
        }
    }

    /// Display the channel carousel units view
    ///
    /// - Parameters:
    ///   - containerView: the channel strip view superview
    ///   - containerViewController: the container view ViewController
    public func display(in containerView: UIView, containerViewController: UIViewController)
    {
        self.containerView = containerView
        self.containerViewController = containerViewController
    }
    
    /// Remove the channel carousel units view
    public func hide()
    {
        fatalError("OVERRIDE ME")
    }
    
    /// Refresh strip / unit content
    public func refreshContent()
    {
        fatalError("OVERRIDE ME")
    }

    /// Hide the story view
    public func hideStory()
    {
        fatalError("OVERRIDE ME")
    }

    /// subscribe to events in order to observe the events messages data.
    /// for Example, subscribe to load and ready events by: `stripView.subscribe(["strip_loaded", "apester_strip_units"])`
    /// - Parameter events: the event names.
    public func subscribe(events: [String])
    {
        DispatchQueue.main.async {
            self.subscribedEvents = self.subscribedEvents.union(events)
        }
    }

    /// unsubscribe from events.
    /// - Parameter events: the event names.
    public func unsubscribe(events: [String])
    {
        DispatchQueue.main.async {
            self.subscribedEvents = self.subscribedEvents.subtracting(events)
        }
    }

    internal func open(_ url: URL)
    {
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

// MARK: - Internal API's to override
@available(iOS 11.0, *)
extension APEController
{
    internal func orientationDidChangeNotification()
    {
        fatalError("OVERRIDE ME")
    }

    internal func open(url: URL, type: APEViewNavigationType)
    {
        fatalError("OVERRIDE ME")
    }

    internal func didFailLoading(error: Error)
    {
        fatalError("OVERRIDE ME")
    }

    internal func didFinishLoading()
    {
        fatalError("OVERRIDE ME")
    }

    internal func handleUserContentController(message: WKScriptMessage)
    {
        fatalError("OVERRIDE ME")
    }

    internal func destroy()
    {
        fatalError("OVERRIDE ME")
    }
}

// MARK: - Handle WebView Presentation
@available(iOS 11.0, * )
private extension APEController
{
    func decisionHandler(navigationAction: WKNavigationAction, webView: WKWebView, completion: (WKNavigationActionPolicy) -> Void)
    {
        
        var policy = WKNavigationActionPolicy.cancel
        // is valid URL
        if let url = navigationAction.request.url {
            switch navigationAction.navigationType {
                case .other:
                    var requestUrlToCheck: String?, webViewUrlToCheck: String?
                    if var requestUrlComponents = URLComponents(string: url.absoluteString) {
                        requestUrlComponents.query = nil

                        requestUrlToCheck = requestUrlComponents.string
                    }
                    
                    if var webViewUrlComponents = URLComponents(string: webView.url?.absoluteString ?? "") {
                        webViewUrlComponents.query = nil

                        webViewUrlToCheck = webViewUrlComponents.string
                    }
                    
                    // redirect when the target is a main frame and the strip has been loaded.
                    if loadingState.isLoaded,
                        let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame,
                        requestUrlToCheck != webViewUrlToCheck,
                        let requestUrlToCheck = requestUrlToCheck,
                        !requestUrlToCheck.contains(Constants.Unit.inAppUnitDetached) {
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

// MARK: - UIAdaptivePresentationControllerDelegate
@available(iOS 11.0, *)
extension APEController : UIAdaptivePresentationControllerDelegate
{
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        self.hideStory()
    }
}

// MARK: - WKScriptMessageHandler
@available(iOS 11.0, *)
extension APEController : WKScriptMessageHandler
{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        DispatchQueue.main.async {
            self.handleUserContentController(message: message)
        }
    }
}

// MARK: - WKNavigationDelegate
@available(iOS 11.0, *)
extension APEController : WKNavigationDelegate
{
    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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

// MARK: - WKUIDelegate
@available(iOS 11.0, *)
extension APEController : WKUIDelegate
{
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let url = navigationAction.request.url {
            self.open(url: url, type: .shareLinkActivated)
        }
        return nil
    }
}

// MARK: - UIScrollViewDelegate
@available(iOS 11.0, *)
extension APEController : UIScrollViewDelegate
{
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

// MARK: - deprecated methods
public extension APEController
{
    @available(*, deprecated, renamed: "display(in:containerViewController:)")
    func display(in containerView: UIView, containerViewConroller: UIViewController) {}
}
#endif
