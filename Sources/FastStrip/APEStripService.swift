//
//  APEStripService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

/// A Proxy Messaging Handler
///
/// Between The Apester Units Carousel component (The `StripWebView`)
/// And the selected Apester Unit (The `StoryWebView`)
open class APEStripService: NSObject {

    private typealias StripConfig = APEConfig.Strip

    class FastStripStoryViewController: UIViewController {
        var webView: WKWebView!

        override func viewDidLoad() {
            super.viewDidLoad()
            self.webView.frame = self.view.bounds
            self.view.addSubview(self.webView)
        }
    }

    // MARK:- Private Properties
    private var stripURL: URL?

    private var messagesTracker = APEStripServiceEventsTracker()

    private var loadingState = APEStripLoadingState()

    private weak var stripRootViewController: UIViewController?
    private var containerView: UIView?
    private var stripStoryViewController: FastStripStoryViewController?

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
        let params = APEStripParams(channelToken: channelToken, shape: .roundSquare, size: .medium, shadow: false)
        self.init(params: params, bundle: bundle)
    }

    public init(params: APEStripParams, bundle: Bundle) {
        super.init()
        let parameters = params.dictionary + APEBundle.bundleInfoPayload(with: bundle)
        self.stripURL = parameters.componentsURL(baseURL: StripConfig.stripUrlPath)
    }

    public func loadStrip(containerView: UIView, rootViewController: UIViewController) {
        self.stripWebView.isUserInteractionEnabled = false
        self.stripWebView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(self.stripWebView)
        self.containerView = containerView
        self.stripRootViewController = rootViewController

        // Auto Layout
        stripWebView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        stripWebView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        stripWebView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        stripWebView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    }

    deinit {
        self.stripWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy])
        self.storyWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy,
                               StripConfig.showStripStory,
                               StripConfig.hideStripStory])
        self.stripWebView.removeFromSuperview()
        self.storyWebView.removeFromSuperview()
        self.stripStoryViewController = nil
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
            if message.webView == stripWebView {
                handleStripWebViewMessages(bodyString)

            } else if message.webView == storyWebView {
                handleStoryWebViewMessages(bodyString)
            }
        }
    }

    func handleStripWebViewMessages(_ bodyString: String) {
        if bodyString.contains(StripConfig.loaded) {
            if let superView = stripWebView.superview, storyWebView.superview == nil {
                superView.addSubview(storyWebView)
            }
            self.loadingState.isLoaded = true

            // get unit height
            if let dictioanry = bodyString.dictionary,
                let heightString = dictioanry[StripConfig.stripHeight] as? String,
                let height = CGFloat(string: heightString) {
                #if os(iOS)
                let adjustedContentInsets = self._stripWebView.scrollView.adjustedContentInset.bottom + self._stripWebView.scrollView.adjustedContentInset.top
                self.loadingState.height = height + adjustedContentInsets
                #endif
            }

        } else if bodyString.contains(StripConfig.initial) {
            self.loadingState.initialMessage = bodyString

        } else if bodyString.contains(StripConfig.open) {
            guard self.loadingState.isReady else {
                self.loadingState.openUnitMessage = bodyString
                return
            }
            self.messagesTracker.sendApesterEvent(message: bodyString, to: storyWebView) { _ in
                self.displayStoryComponent()
            }
        }
        // proxy updates
        if self.messagesTracker.canSendApesterEvent(message: bodyString, to: storyWebView) {
            self.messagesTracker.sendApesterEvent(message: bodyString, to: storyWebView)
        }
    }

    func handleStoryWebViewMessages(_ bodyString: String) {
        if bodyString.contains(StripConfig.isReady) {
            self.loadingState.isReady = true
            // update delegate
            self.stripComponentIsReady(height: self.loadingState.height)
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

        } else if bodyString.contains(StripConfig.off) {
            self.hideStoryComponent()
        }
        // proxy updates
        if self.messagesTracker.canSendApesterEvent(message: bodyString, to: stripWebView) {
            self.messagesTracker.sendApesterEvent(message: bodyString, to: stripWebView)
        }
    }

    func displayStoryComponent() {
        if let rootVC = self.stripRootViewController {
            self.stripStoryViewController = FastStripStoryViewController()
            self.stripStoryViewController?.webView = self.storyWebView
            rootVC.present(self.stripStoryViewController!, animated: true, completion: nil)
        }
        self.delegate?.displayStoryComponent()
    }

    func stripComponentIsReady(height: CGFloat) {
        self.containerView.flatMap({ containerView in
            UIView.animate(withDuration: 0.33) {
                self.stripWebView.isUserInteractionEnabled = true
                // Auto Layout
                containerView.constraints.first(where: { $0.firstAttribute == .height })?.isActive = false
                containerView.heightAnchor.constraint(equalToConstant: height).isActive = true
                containerView.layoutIfNeeded()
            }
        })
        self.delegate?.stripComponentIsReady(unitHeight: self.loadingState.height)
    }

    func hideStoryComponent() {
        if let stripStoryViewController = self.stripStoryViewController {
            stripStoryViewController.dismiss(animated: true, completion: nil)
        }
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
        decisionHandler(.allow)
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

