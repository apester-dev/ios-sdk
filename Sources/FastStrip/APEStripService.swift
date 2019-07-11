//
//  APEStripService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit
import SafariServices

#if os(iOS)
/// A Proxy Messaging Handler
///
/// Between The Apester Units Carousel component (The `StripWebView`)
/// And the selected Apester Unit (The `StoryWebView`)
open class APEStripService: NSObject {

    private typealias StripConfig = APEConfig.Strip


    class FastStripStoryViewController: UIViewController {
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

    private var spinner = UIActivityIndicatorView(style: .whiteLarge)
    private weak var stripRootViewController: UIViewController?
    private var containerView: UIView?

    private lazy var stripStoryViewController: FastStripStoryViewController = {
        let stripStoryVC = FastStripStoryViewController()
        stripStoryVC.webView = self.storyWebView
        return stripStoryVC
    }()

    // MARK:- Private Properties
    private var stripURL: URL?

    private var messagesTracker = APEStripServiceEventsTracker()

    private var loadingState = APEStripLoadingState()

    private lazy var _stripWebView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        webView.configuration.userContentController.register(to: [StripConfig.proxy], delegate: self)
        if let url = self.stripURL {
            webView.load(URLRequest(url: url))
        }
        return webView
    }()

    private lazy var _storyWebView: WKWebView  = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        webView.configuration.userContentController
            .register(to: [StripConfig.proxy,
                           StripConfig.showStripStory,
                           StripConfig.hideStripStory],
                      delegate: self)
        if let storyUrl = URL(string: StripConfig.stripStoryUrlPath) {
            webView.load(URLRequest(url: storyUrl))
        }
        return webView
    }()

    // MARK:- Public Properties
    public weak var dataSource: APEStripServiceDataSource?
    public weak var delegate: APEStripServiceDelegate?

    public var stripWebView: WKWebView { return _stripWebView }
    public var storyWebView: WKWebView { return _storyWebView }

    // MARK:- Initializer
    convenience public init(channelToken: String, bundle: Bundle) {
        let params = APEStripParams(channelToken: channelToken, shape: .roundSquare, size: .medium, shadow: false, bundle: bundle)
        self.init(params: params)
    }

    public init(params: APEStripParams) {
        super.init()
        self.stripURL = params.url
    }

    public func displayStripComponent(in containerView: UIView, rootViewController: UIViewController) {

        containerView.layoutIfNeeded()
        self.stripWebView.frame = containerView.bounds
        containerView.addSubview(self.stripWebView)

        self.containerView = containerView
        self.stripRootViewController = rootViewController

        stripWebView.isUserInteractionEnabled = false
        stripWebView.alpha = 0.5

        containerView.addSubview(spinner)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: stripWebView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: stripWebView.centerYAnchor).isActive = true

    }

    deinit {
        self.stripWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy])
        self.stripWebView.removeFromSuperview()
        self.storyWebView.removeFromSuperview()
    }
}

// MARK:- UserContentController Script Messages Handle
private extension APEStripService {
    func handleUserContentController(message: WKScriptMessage) {
        if message.name == StripConfig.showStripStory {
            if let showStoryFunction = self.dataSource?.showStoryFunction {
                self.messagesTracker.evaluateJavaScript(message: showStoryFunction,
                                                        to: self.storyWebView)
            }

        } else if message.name == StripConfig.hideStripStory {
            if let hideStoryFunction = self.dataSource?.hideStoryFunction {
                self.messagesTracker.evaluateJavaScript(message: hideStoryFunction,
                                                        to: self.storyWebView)
            }

        } else if let bodyString = message.body as? String {
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
                superView.addSubview(storyWebView)
            }
            self.loadingState.isLoaded = true
            // get unit height
            if let dictioanry = bodyString.dictionary,
                let heightString = dictioanry[StripConfig.stripHeight] as? String,
                let height = Float(string: heightString) {

                let adjustedContentInsets = self._stripWebView.scrollView.adjustedContentInset.bottom + self._stripWebView.scrollView.adjustedContentInset.top
                self.loadingState.height = height + Float(adjustedContentInsets)
                self.updateStripComponentHeight()
            }

        } else if bodyString.contains(StripConfig.open) {
            guard self.loadingState.isReady else {
                self.loadingState.openUnitMessage = bodyString
                return
            }
            self.messagesTracker.sendApesterEvent(message: bodyString, to: storyWebView) { _ in
                self.displayStoryComponent()
            }
        }  else if bodyString.contains(StripConfig.destroy) {
            self.loadingState.height = 0.0
            self.containerView?.alpha = 0.0
            self.updateStripComponentHeight()
        }
        // proxy updates
        if self.messagesTracker.canSendApesterEvent(message: bodyString, to: storyWebView) {
            self.messagesTracker.sendApesterEvent(message: bodyString, to: storyWebView)
        }
    }

    func updateStripComponentHeight() {
        self.containerView.flatMap { containerView in
            UIView.animate(withDuration: 0.33) {
                // Auto Layout
                containerView.frame.size.height = CGFloat(self.loadingState.height)
                self.stripWebView.frame = containerView.bounds
            }
        }
        self.delegate?.stripComponentIsReady(unitHeight: self.loadingState.height)
    }

    func handleStoryWebViewMessages(_ bodyString: String) {
        if bodyString.contains(StripConfig.isReady) {
            self.loadingState.isReady = true

            self.stripWebView.isUserInteractionEnabled = true
            stripWebView.alpha = 1
            spinner.removeFromSuperview()
            // send openUnitMessage if needed
            if let openUnitMessage = self.loadingState.openUnitMessage {
                self.messagesTracker.sendApesterEvent(message: openUnitMessage, to: storyWebView) { _ in
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
        if self.messagesTracker.canSendApesterEvent(message: bodyString, to: stripWebView) {
            self.messagesTracker.sendApesterEvent(message: bodyString, to: stripWebView)
        }
    }

    func displayStoryComponent() {
            self.stripRootViewController?.present(self.stripStoryViewController, animated: true, completion: nil)
        self.delegate?.displayStoryComponent()
    }

    func hideStoryComponent() {
        self.stripStoryViewController.dismiss(animated: true) {}
        self.delegate?.hideStoryComponent()
    }
}

// MARK:- WKScriptMessageHandler
extension APEStripService: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.main.async {
            self.handleUserContentController(message: message)
        }
    }
}

// MARK:- WKNavigationDelegate
extension APEStripService: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let initialMessage = self.loadingState.initialMessage {
            self.messagesTracker.sendApesterEvent(message: initialMessage, to: self.storyWebView) { _ in
                self.loadingState.initialMessage = nil
            }
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var policy = WKNavigationActionPolicy.cancel
        switch navigationAction.navigationType {
        case .other, .reload, .backForward:
            policy = .allow
        case .linkActivated, .formSubmitted, .formResubmitted:
            guard let url = navigationAction.request.url else {
                return
            }
            self.stripStoryViewController.present(SFSafariViewController(url: url), animated: true, completion: nil)
        default: break
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

#endif
