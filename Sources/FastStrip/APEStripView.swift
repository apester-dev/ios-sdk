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
/// A ChannelToken Loading state update
@objc public protocol APEStripViewDelegate: NSObjectProtocol {


    /// when the ChannelToken loaded successfuly
    ///
    /// - Parameter stripView: the strip view updater
    /// - Parameter token: the channel token id
    func stripView(_ stripView: APEStripView, didFinishLoadingChannelToken token:String)


    /// when the ChannelToken couldn't be loaded
    ///
    /// - Parameter stripView: the strip view updater
    /// - Parameter token: the channel token id
    func stripView(_ stripView: APEStripView, didFailLoadingChannelToken token:String)


    /// when the stripView height has been updated
    ///
    /// - Parameter stripView: the strip view updater
    /// - Parameter height: the stripView new height
    func stripView(_ stripView: APEStripView, didUpdateHeight height:CGFloat)
}

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

    private class FastStripStoryViewController: UIViewController {
        var webView: WKWebView?

        override func viewDidLoad() {
            super.viewDidLoad()
            self.webView!.frame = self.view.bounds
            self.view.addSubview(self.webView!)
        }

        deinit {
            self.webView?.configuration.userContentController
                .unregister(from: [StripConfig.proxy,
                                   StripConfig.showStripStory,
                                   StripConfig.hideStripStory])
        }
    }

    private typealias StripConfig = Constants.Strip

    private var lastDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation

    private weak var stripContainerViewConroller: UIViewController?
    private var containerView: UIView?

    private lazy var stripStoryViewController: FastStripStoryViewController = {
        let stripStoryVC = FastStripStoryViewController()
        stripStoryVC.webView = self.storyWebView
        return stripStoryVC
    }()

    // MARK:- Private Properties
    public private(set) var configuration: APEStripConfiguration!

    private var messageDispatcher = MessageDispatcher()

    private var loadingState = LoadingState() {
        didSet {
            if loadingState.height != oldValue.height, loadingState.isLoaded {
                self.updateStripWebView(height: loadingState.height)
            }
        }
    }

    private var stripWebViewHeightConstraint: NSLayoutConstraint?
    private lazy var stripWebView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.insetsLayoutMarginsFromSafeArea = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.delegate = self
        webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.configuration.userContentController.register(to: [StripConfig.proxy], delegate: self)
        if let url = self.configuration?.stripURL {
            webView.load(URLRequest(url: url))
        }
        return webView
    }()

    private lazy var storyWebView: WKWebView  = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.insetsLayoutMarginsFromSafeArea = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.delegate = self
        webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.configuration.userContentController
            .register(to: [StripConfig.proxy, StripConfig.showStripStory, StripConfig.hideStripStory], delegate: self)
        if let storyUrl = self.configuration?.storyURL {
            webView.load(URLRequest(url: storyUrl))
        }
        return webView
    }()

    private let setDeviceOrientation: ((Int) -> Void) = { UIDevice.current.setValue($0, forKey: "orientation") }

    public weak var delegate: APEStripViewDelegate?

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

    // MARK:- Initializer
    /// init with configuration
    ///
    /// - Parameter configuration: the strip view custom configuration, i.e channelToken, shape, size
    public init(configuration: APEStripConfiguration) {
        super.init()
        self.configuration = configuration
        // prefetch channel data...
        _ = self.stripWebView
        _ = self.storyWebView
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let stronSelf = self, let containerView = stronSelf.containerView, let stripContainerViewConroller = stronSelf.stripContainerViewConroller else {
                return
            }
            // validate that when the stripStoryViewController is presented the orientation must be portrait mode
            if stronSelf.stripStoryViewController.presentingViewController != nil, !UIDevice.current.orientation.isPortrait {
                stronSelf.lastDeviceOrientation = UIDevice.current.orientation
                stronSelf.setDeviceOrientation(UIInterfaceOrientation.portrait.rawValue)
                return
            }
            // reload stripWebView
            stronSelf.stripWebView.reload()
            stronSelf.stripWebView.removeFromSuperview()
            stronSelf.display(in: containerView, containerViewConroller: stripContainerViewConroller)
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
        self.stripContainerViewConroller = containerViewConroller
    }

    /// Remove the channel carousel units view
    public func hide() {
        self.stripWebView.removeFromSuperview()
        self.storyWebView.removeFromSuperview()
    }

    deinit {
        hide()
        destroy()
    }
}

// MARK:- Handle UserContentController Script Messages
@available(iOS 11.0, *)
private extension APEStripView {
    func handleUserContentController(message: WKScriptMessage) {
        if let bodyString = message.body as? String {
            if message.webView?.hash == stripWebView.hash {
                handleStripWebViewMessages(bodyString)
            } else if message.webView?.hash == storyWebView.hash {
                handleStoryWebViewMessages(bodyString)
            }
        }
    }

    func handleStripWebViewMessages(_ bodyString: String) {
        if bodyString.contains(StripConfig.initial) {
            self.loadingState.initialMessage = bodyString

        } else if bodyString.contains(StripConfig.loaded) {
            if let superView = stripWebView.superview, storyWebView.superview == nil {
                superView.insertSubview(storyWebView, belowSubview: stripWebView)
            }
            //
            stripWebView.appendAppNameToUserAgent(self.configuration.bundleInfo)
            storyWebView.appendAppNameToUserAgent(self.configuration.bundleInfo)
            //
            self.loadingState.isLoaded = true
            // update the delegate on success
            self.delegate?.stripView(self, didFinishLoadingChannelToken: self.configuration.channelToken)

        } else if bodyString.contains(StripConfig.stripResizeHeight),
            let dictioanry = bodyString.dictionary, let height = dictioanry[StripConfig.stripHeight] as? CFloat {
            if CGFloat(height) != self.loadingState.height {
                self.loadingState.height = CGFloat(height)
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
        // proxy updates
        if !self.messageDispatcher.contains(message: bodyString, for: storyWebView) {
            self.messageDispatcher.dispatch(apesterEvent: bodyString, to: storyWebView)
        }
    }

    func updateStripWebView(height: CGFloat) {
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
        self.lastDeviceOrientation = UIDevice.current.orientation
        if self.lastDeviceOrientation.isLandscape {
            setDeviceOrientation(UIInterfaceOrientation.portrait.rawValue)
        }
        self.stripContainerViewConroller?.present(self.stripStoryViewController, animated: true, completion: nil)
    }

    func hideStoryComponent() {
        self.stripStoryViewController.dismiss(animated: false) {
            if self.lastDeviceOrientation.isLandscape {
                self.setDeviceOrientation(self.lastDeviceOrientation.rawValue)
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

    func redirect(_ url: URL) {
        guard let scheme = url.scheme, scheme.contains("http") else { return }
        let presntedVC = self.stripContainerViewConroller?.presentedViewController ?? self.stripContainerViewConroller
        presntedVC?.present(SFSafariViewController(url: url), animated: true, completion: nil)
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
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let initialMessage = self.loadingState.initialMessage {
            self.messageDispatcher.dispatch(apesterEvent: initialMessage, to: self.storyWebView) { _ in
                self.loadingState.initialMessage = nil
            }
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var policy = WKNavigationActionPolicy.cancel
        // is valid URL
        if let url = navigationAction.request.url {
            switch navigationAction.navigationType {
            case .other, .reload, .formSubmitted:
                // redirect when the target is a main frame and the strip has been loaded.
                if loadingState.isLoaded, let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame {
                    redirect(url)
                } else {
                    policy = .allow // allow webview requests communication
                }
            case .linkActivated:
                // redirect when the main web view link got clickd.
                redirect(url)
            default: break
            }
        }
        decisionHandler(policy)
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
// MARK:- WKScriptMessageHandler
@available(iOS 11.0, *)
extension APEStripView: UIScrollViewDelegate {
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
#endif
