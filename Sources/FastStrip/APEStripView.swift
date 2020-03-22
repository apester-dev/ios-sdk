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
@objcMembers public class APEStripView: APEView {

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
        
        func destroy() {
//            self.webView.removeFromSuperview()
        }
    }

    public private(set) var configuration: APEStripConfiguration!
    private var storyViewController: StripStoryViewController!
    private typealias StripConfig = Constants.Strip

    // MARK:- Private Properties
    private var stripWebViewHeightConstraint: NSLayoutConstraint?

    private var stripWebView: WKWebView!
    private var storyWebView: WKWebView!

    public weak var delegate: APEStripViewDelegate?

    // MARK:- Public Properties
    public override var height: CGFloat {
        guard self.loadingState.isLoaded else {
            return .zero
        }
        var calculatedHeight: CGFloat = self.loadingState.height
        self.messageDispatcher.dispatchSync(message: Constants.WebView.getHeight, to: self.stripWebView) { response in
            calculatedHeight = (response as? CGFloat) ?? calculatedHeight
        }
        return calculatedHeight
    }
    
    /// The strip view visibility status, update this property either when the strip view is visible or not.
    public override var isDisplayed: Bool {
        didSet {
            self.messageDispatcher
                .dispatchAsync(Constants.WebView.setViewVisibilityStatus(isDisplayed),
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
        super.init(configuration.environment)
        self.configuration = configuration
        // prefetch channel data...
        self.prepareStripView()
    }

    /// Display the channel carousel units view
    ///
    /// - Parameters:
    ///   - containerView: the channel strip view superview
    ///   - containerViewConroller: the container view ViewController
    public override func display(in containerView: UIView, containerViewConroller: UIViewController) {
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
        super.display(in: containerView, containerViewConroller: containerViewConroller)
    }

    /// Remove the channel carousel units view
    public override func hide() {
        self.stripWebView.removeFromSuperview()
        self.storyWebView.removeFromSuperview()
    }

    /// Hide the story view
    public override func hideStory() {
        self.messageDispatcher.dispatchAsync(Constants.WebView.close, to: self.storyWebView)
    }

    /// subscribe to events in order to observe the events messages data.
    /// for Example, subscribe to load and ready events by: `stripView.subscribe(["strip_loaded", "apester_strip_units"])`
    /// - Parameter events: the event names.
    public override func subscribe(events: [String]) {
        DispatchQueue.main.async {
            self.subscribedEvents = self.subscribedEvents.union(events)
        }
    }

    /// unsubscribe from events.
    /// - Parameter events: the event names.
    public override func unsubscribe(events: [String]) {
        DispatchQueue.main.async {
            self.subscribedEvents = self.subscribedEvents.subtracting(events)
        }
    }

    deinit {
        hide()
        destroy()
    }
}

// MARK: - Override internal APIs
@available(iOS 11.0, *)
@objc extension APEStripView {

    // MARK:- Handle Device orientationDidChangeNotification
    override func orientationDidChangeNotification() {
        guard let containerView = self.containerView, let viewConroller = self.containerViewConroller else { return }
        // validate that when the stripStoryViewController is presented the orientation must be portrait mode
        if self.storyViewController.presentingViewController != nil, !UIDevice.current.orientation.isPortrait {
            self.setDeviceOrientation(UIInterfaceOrientation.portrait.rawValue)
            return
        }
        self.lastDeviceOrientation = UIDevice.current.orientation
        // reload stripWebView
        self.stripWebView.removeFromSuperview()
        self.display(in: containerView, containerViewConroller: viewConroller)
    }

    override func open(url: URL, type: APEViewNavigationType) {
        // wait for shouldHandleURL callback
        let shouldHandleURL: Void? = self.delegate?.stripView?(self, shouldHandleURL: url, type: type) {
            if !$0 { self.open(url) }
        }
        // check if the shouldHandleURL is implemented
        if shouldHandleURL == nil {
            self.open(url)
        }
    }

    override func didFailLoading(error: Error) {
        self.delegate?.stripView(self, didFailLoadingChannelToken: self.channelToken)
    }

    override func didFinishLoading() {
        if let initialMessage = self.loadingState.initialMessage {
            self.messageDispatcher.dispatch(apesterEvent: initialMessage, to: self.storyWebView) { _ in
                self.loadingState.initialMessage = nil
            }
        }
    }

    override func handleUserContentController(message: WKScriptMessage) {
        if let bodyString = message.body as? String {
            if message.webView?.hash == stripWebView.hash {
                handleStripWebViewMessages(bodyString, messageName: message.name)
            } else if message.webView?.hash == storyWebView.hash {
                handleStoryWebViewMessages(bodyString)
            }
            self.publish(message: bodyString)
        }
    }

    override func destroy() {
        self.stripWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy])
        self.storyWebView.configuration.userContentController
            .unregister(from: [StripConfig.proxy,
                               StripConfig.showStripStory,
                               StripConfig.hideStripStory])
    }
    
    public override func refreshContent() {

        self.loadingState.isReady = false
        self.storyWebView.removeFromSuperview()

        setupStoryWebView()
        setupStoryViewController()
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.refreshContent,
                                      to: self.stripWebView)
    }
}

// MARK:- Private
@available(iOS 11.0, *)
private extension APEStripView {
    private var channelToken: String { self.configuration.channelToken }
    // Setup
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
        if let url = self.configuration.stripURL {
            self.stripWebView.load(URLRequest(url: url))
        }
    }

    func setupStoryWebView() {
        let options = WKWebView.Options(events: [StripConfig.proxy, StripConfig.showStripStory, StripConfig.hideStripStory],
                                        contentBehavior: .always,
                                        delegate: self)
        self.storyWebView = WKWebView.make(with: options)
        if let url = self.configuration.storyURL {
            self.storyWebView.load(URLRequest(url: url))
        }
    }

    func setupStoryViewController() {
        let storyVC = StripStoryViewController()
        storyVC.webView = self.storyWebView
        self.storyViewController = storyVC
    }

    // Handle UserContentController Script Messages
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
            self.delegate?.stripView(self, didFinishLoadingChannelToken: self.channelToken)

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
            delegate?.stripView(self, didFailLoadingChannelToken: self.channelToken)
        }
        else if bodyString.contains(Constants.WebView.apesterAdsCompleted) {
            
            // update the delegate on all ads completed
            self.delegate?.stripView(self, didCompleteAdsForChannelToken: self.channelToken)
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
extension APEStripView {
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
}
#endif
