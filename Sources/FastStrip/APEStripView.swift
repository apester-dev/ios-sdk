//
//  APEStripView.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
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
@objcMembers public class APEStripView: NSObject {

    private struct LoadingState {
        var isLoaded = false
        var isReady = false
        var height: CGFloat = 10
        var initialMessage: String?
        var openUnitMessage: String?
    }

    private class StripStoryViewController: UIViewController {
        var webView: WKWebView!

        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.addSubview(self.webView)
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            self.webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            self.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            self.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }

    private typealias StripConfig = Constants.Strip

    private var lastDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    private let setDeviceOrientation: ((Int) -> Void) = { UIDevice.current.setValue($0, forKey: "orientation") }

    private var containerView: UIView?
    private weak var containerViewConroller: UIViewController?
    private var storyViewController: StripStoryViewController!

    // MARK:- Private Properties
    public private(set) var configuration: APEStripConfiguration!

    private var messageDispatcher = MessageDispatcher()

    private var loadingState = LoadingState()

    private var subscribedEvents: Set<String> = Set()

    private var stripWebViewHeightConstraint: NSLayoutConstraint?

    private var stripWebView: WKWebView!
    private var storyWebView: WKWebView!

    public weak var delegate: APEStripViewDelegate?

    // MARK:- Public Properties
    public var height: CGFloat {
        guard self.loadingState.isLoaded else {
            return .zero
        }
        var calculatedHeight: CGFloat = self.loadingState.height
        self.messageDispatcher.dispatchSync(message: Constants.Strip.getHeight, to: self.stripWebView) { response in
            calculatedHeight = (response as? CGFloat) ?? calculatedHeight
        }
        return calculatedHeight
    }
    
    /// The strip view visibility status, update this property either when the strip view is visible or not.
    public var isDisplayed: Bool = false {
        didSet {
            self.messageDispatcher
                .dispatchAsync(Constants.Strip.setViewVisibilityStatus(isDisplayed),
                               to: self.stripWebView)
        }
    }

    // MARK:- Initializer
    /// init with configuration and UIapplication
    ///   `````
    /// // FYI, in order to open URLs like WhatsApp Application
    /// // The Info.plist file must include the query schemes for that app, i,e:
    ///   <key>LSApplicationQueriesSchemes</key>
    ///     <array>
    ///       <string>whatsapp</string>
    ///     </array>
    ///   `````
    /// - Parameters:
    ///   - configuration: the strip view custom configuration, i.e channelToken, shape, size
    public init(configuration: APEStripConfiguration) {
        super.init()
        self.configuration = configuration
        // prefetch channel data...
        self.prepareStripView()
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let strongSelf = self, let containerView = strongSelf.containerView, let viewConroller = strongSelf.containerViewConroller else {
                return
            }
            // validate that when the stripStoryViewController is presented the orientation must be portrait mode
            if strongSelf.storyViewController.presentingViewController != nil, !UIDevice.current.orientation.isPortrait {
                strongSelf.setDeviceOrientation(UIInterfaceOrientation.portrait.rawValue)
                return
            }
            strongSelf.lastDeviceOrientation = UIDevice.current.orientation
            // reload stripWebView
            strongSelf.stripWebView.removeFromSuperview()
            strongSelf.display(in: containerView, containerViewConroller: viewConroller)
        }

    }

    /// Display the channel carousel units view
    ///
    /// - Parameters:
    ///   - containerView: the channel strip view superview
    ///   - containerViewConroller: the container view ViewController
    public func display(in containerView: UIView, containerViewConroller: UIViewController) {
        // update stripWebView frame according to containerView bounds
        containerView.layoutIfNeeded()
        containerView.addSubview(self.stripWebView)
        stripWebView.translatesAutoresizingMaskIntoConstraints = false
        stripWebView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        stripWebView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        stripWebView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        stripWebViewHeightConstraint = stripWebView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        stripWebViewHeightConstraint?.priority = .defaultLow
        stripWebViewHeightConstraint?.isActive = true
        self.containerView = containerView
        self.containerViewConroller = containerViewConroller
    }

    /// Remove the channel carousel units view
    public func hide() {
        self.stripWebView.removeFromSuperview()
        self.storyWebView.removeFromSuperview()
    }

    /// Hide the story view
    public func hideStory() {
        self.messageDispatcher.dispatchAsync(Constants.Strip.close, to: self.storyWebView)
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

    deinit {
        hide()
        destroy()
    }
}
// MARK:- Setup
@available(iOS 11.0, *)
private extension APEStripView {

    func prepareStripView() {
        setupStripWebView()
        setupStoryWebView()
        setupStoryViewController()
    }

    func setupStripWebView() {
        let options = WKWebView.Options(events: [StripConfig.proxy, StripConfig.validateStripViewVisibity],
                                        contentBehavior: .never,
                                        delegate: self)
        self.stripWebView = WKWebView.make(with: options)
        if let url = self.configuration?.stripURL {
            self.stripWebView.load(URLRequest(url: url))
        }
    }

    func setupStoryWebView() {
        let options = WKWebView.Options(events: [StripConfig.proxy, StripConfig.showStripStory, StripConfig.hideStripStory],
                                        contentBehavior: .always,
                                        delegate: self)
        self.storyWebView = WKWebView.make(with: options)
        if let storyUrl = self.configuration?.storyURL {
            self.storyWebView.load(URLRequest(url: storyUrl))
        }
    }

    func setupStoryViewController() {
        let storyVC = StripStoryViewController()
        storyVC.webView = self.storyWebView
        self.storyViewController = storyVC
    }
}
// MARK:- Handle UserContentController Script Messages
@available(iOS 11.0, *)
private extension APEStripView {
    func handleUserContentController(message: WKScriptMessage) {
        if let bodyString = message.body as? String {
            if message.webView?.hash == stripWebView.hash {
                handleStripWebViewMessages(bodyString, messageName: message.name)
            } else if message.webView?.hash == storyWebView.hash {
                handleStoryWebViewMessages(bodyString)
            }
            self.publish(message: bodyString)
        }
    }

    func publish(message: String) {
        guard let event = self.subscribedEvents.first(where: { message.contains($0) }) else { return }
        if self.subscribedEvents.contains(event) {
            self.delegate?.stripView?(self, didReciveEvent: event, message: message)
        }
    }

    func handleStripWebViewMessages(_ bodyString: String, messageName: String) {
        if bodyString.contains(StripConfig.initial) {
            self.loadingState.initialMessage = bodyString

        } else if bodyString.contains(StripConfig.loaded) {
            if storyWebView.superview == nil {
                self.storyViewController.viewDidLoad()
            }
            //
            stripWebView.appendAppNameToUserAgent(self.configuration.bundleInfo)
            storyWebView.appendAppNameToUserAgent(self.configuration.bundleInfo)
            //
            self.loadingState.isLoaded = true
            self.updateStripWebViewHeight()
            // update the delegate on success
            self.delegate?.stripView(self, didFinishLoadingChannelToken: self.configuration.channelToken)

        } else if bodyString.contains(StripConfig.stripResizeHeight),
            let dictioanry = bodyString.dictionary, let height = dictioanry[StripConfig.stripHeight] as? CFloat {
            if CGFloat(height) != self.loadingState.height {
                self.loadingState.height = CGFloat(height)
                if loadingState.isLoaded {
                    self.updateStripWebViewHeight()
                }
            }

        } else if bodyString.contains(StripConfig.open) {
            guard self.loadingState.isReady else {
                self.loadingState.openUnitMessage = bodyString
                return
            }
            self.messageDispatcher.dispatch(apesterEvent: bodyString, to: storyWebView) { _ in
                self.displayStoryComponent()
            }
        }  else if bodyString.contains(StripConfig.destroy) {
            // update the delegate on fail or hide if needed
            self.destroy()
            self.loadingState.isLoaded = false
            delegate?.stripView(self, didFailLoadingChannelToken: self.configuration.channelToken)
        }
        else if messageName == StripConfig.validateStripViewVisibity {
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
        // proxy updates
        if !self.messageDispatcher.contains(message: bodyString, for: storyWebView) {
            self.messageDispatcher.dispatch(apesterEvent: bodyString, to: storyWebView)
        }
    }

    func updateStripWebViewHeight() {
        let height = self.loadingState.height
        // 1 - update the stripWebView height constraint
        self.stripWebViewHeightConstraint.flatMap { NSLayoutConstraint.deactivate([$0]) }
        stripWebViewHeightConstraint = stripWebView.heightAnchor.constraint(equalToConstant: height)
        stripWebViewHeightConstraint?.priority = .defaultHigh
        stripWebViewHeightConstraint?.isActive = true

        // 2 - update the strip containerView height constraint
        self.containerView?.constraints
            .first(where: { $0.firstAttribute == .height })
            .flatMap { NSLayoutConstraint.deactivate([$0]) }
        let containerViewHeightConstraint = self.containerView?.heightAnchor.constraint(equalToConstant: height)
        containerViewHeightConstraint?.priority = .defaultHigh
        containerViewHeightConstraint?.isActive = true

        // 3 - update the delegate about the new height
        self.delegate?.stripView(self, didUpdateHeight: height)
    }

    func handleStoryWebViewMessages(_ bodyString: String) {
        if bodyString.contains(StripConfig.isReady) {
            self.loadingState.isReady = true

            // send openUnitMessage if needed
            if let openUnitMessage = self.loadingState.openUnitMessage {
                self.messageDispatcher.dispatch(apesterEvent: openUnitMessage, to: storyWebView) { _ in
                    self.loadingState.openUnitMessage = nil
                }
            }

        } else if bodyString.contains(StripConfig.next) {
            if self.loadingState.initialMessage != nil {
                self.loadingState.initialMessage = nil
            }

        } else if (bodyString.contains(StripConfig.off) || bodyString.contains(StripConfig.destroy)) {
            self.hideStoryComponent()
        }

        // proxy updates
        if !self.messageDispatcher.contains(message: bodyString, for: stripWebView) {
            self.messageDispatcher.dispatch(apesterEvent: bodyString, to: stripWebView)
        }
    }
}

// MARK:- Handle WebView Presentation
@available(iOS 11.0, * )
private extension APEStripView {
    func displayStoryComponent() {
        DispatchQueue.main.async {
            self.lastDeviceOrientation = UIDevice.current.orientation
            if self.lastDeviceOrientation.isLandscape {
                self.setDeviceOrientation(UIInterfaceOrientation.portrait.rawValue)
            }
            guard let containerViewConroller = self.containerViewConroller, self.storyViewController.presentingViewController == nil else { return }
            self.storyViewController.dismiss(animated: false, completion: nil)
            self.storyViewController.presentationController?.delegate = self
            (containerViewConroller.presentingViewController ?? containerViewConroller).present(self.storyViewController, animated: true) {}
        }
    }

    func hideStoryComponent() {
        DispatchQueue.main.async {
            self.storyViewController.dismiss(animated: true) {
                if self.lastDeviceOrientation.isLandscape {
                    self.setDeviceOrientation(self.lastDeviceOrientation.rawValue)
                }
            }
        }
    }

    func destroy() {
        self.stripWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy])
        self.storyWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy,
                               StripConfig.showStripStory,
                               StripConfig.hideStripStory])
    }

    func open(url: URL, type: APEStripViewNavigationType) {
        let open: ((URL) -> Void) = { url in
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { _ in }
                }
            }
        }
        // wait for shouldHandleURL callback
        let shouldHandleURL: Void? = self.delegate?.stripView?(self, shouldHandleURL: url, type: type) {
            if !$0 { open(url) }
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
private extension UIView {
    var allSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.allSubviews }
    }

}
// MARK: UIAdaptivePresentationControllerDelegate
@available(iOS 11.0, *)
extension APEStripView: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.hideStory()
    }
}

// MARK:- WKScriptMessageHandler
@available(iOS 11.0, *)
extension APEStripView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.main.async {
            self.handleUserContentController(message: message)
        }
    }
}

// MARK:- WKNavigationDelegate
@available(iOS 11.0, *)
extension APEStripView: WKNavigationDelegate {

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
        self.loadingState.isLoaded = false
        self.delegate?.stripView(self, didFailLoadingChannelToken: self.configuration.channelToken)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let initialMessage = self.loadingState.initialMessage {
            self.messageDispatcher.dispatch(apesterEvent: initialMessage, to: self.storyWebView) { _ in
                self.loadingState.initialMessage = nil
            }
        }
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
extension APEStripView: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            self.open(url: url, type: .shareLinkActivated)
        }
        return nil
    }
}

// MARK:- WKScriptMessageHandler
@available(iOS 11.0, *)
extension APEStripView: UIScrollViewDelegate {
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
#endif
