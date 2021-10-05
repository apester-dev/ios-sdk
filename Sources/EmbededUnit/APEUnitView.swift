//
//  APEUnitWebView.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import WebKit
import Foundation
import OpenWrapSDK
import GoogleMobileAds

@objcMembers public class APEUnitView: APEView {
    
    // POBBannerViews
    private lazy var pubMaticViewCloseButton: UIButton = {
        var button: UIButton!
        button = UIButton(type: .custom)
        button.setTitle("🅧", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(hidePubMaticView), for: .touchUpInside)
        return button
    }()
    
    private var pubMaticViews: [PubMaticProviderParams.AdType: POBBannerView] = [:]
    private var pubMaticViewDelegates: [PubMaticProviderParams.AdType: PubMaticViewDelegate] = [:]
    private var pubMaticViewTimer: Timer?
    
    // GADBannerView
    private var gADViews: [AdMobProviderParams: GADBannerView] = [:]
    private var gADViewDelegates: [AdMobProviderParams: GADViewDelegate] = [:]
    
    private var unitWebViewHeightConstraint: NSLayoutConstraint?
    private var unitWebViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - API
    public private(set) var unitWebView: WKWebView!
    
    public private(set) var configuration: APEUnitConfiguration!
    public weak var delegate: APEUnitViewDelegate?
    
    /// The view visibility status, update this property either when the view is visible or not.
    public override var isDisplayed: Bool {
        didSet {
            self.messageDispatcher
                .dispatchAsync(Constants.WebView.setViewVisibilityStatus(isDisplayed),
                               to: self.unitWebView)
        }
    }
    
    /// subscribe to events in order to observe the events messages data.
    /// for Example, subscribe to load and ready events by: `unitView.subscribe(["apester_interaction_loaded", "click_next"])`
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

    public override var height: CGFloat {
        guard self.loadingState.isLoaded else {
            return .zero
        }
        return self.loadingState.height
    }
    
    public init(configuration: APEUnitConfiguration) {
        super.init(configuration.environment)
        
        self.configuration = configuration
        let options = WKWebView.Options(events: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibility], contentBehavior: .never, delegate: self)
        
        self.unitWebView = WKWebView.make(with: options, params: configuration.parameters)
        
        if let unitUrl = configuration.unitURL {
            unitWebView.load(URLRequest(url: unitUrl))
        }
    }
    
    public override func display(in containerView: UIView, containerViewController: UIViewController) {
        super.display(in: containerView, containerViewController: containerViewController)
        // update unitWebView frame according to containerView bounds
        containerView.layoutIfNeeded()
        containerView.addSubview(self.unitWebView)
        unitWebView.translatesAutoresizingMaskIntoConstraints = false
        unitWebView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        unitWebView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        unitWebView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        unitWebViewHeightConstraint = constraint(for: unitWebView.heightAnchor, equalTo: containerView.heightAnchor)
        unitWebViewHeightConstraint?.priority = .defaultLow
        unitWebViewHeightConstraint?.isActive = true

        unitWebViewWidthConstraint = constraint(for: unitWebView.widthAnchor, equalTo: containerView.widthAnchor)
        unitWebViewWidthConstraint?.priority = .defaultLow
        unitWebViewWidthConstraint?.isActive = true
        // show AD Views
        showPubMaticViews()
        showGADView()
    }
    
    /// Remove the unit web view
    public override func hide() {
        self.unitWebView.removeFromSuperview()
    }
    
    public func setGdprString(_ gdprString: String) {
        
        self.configuration.gdprString = gdprString
        if let unitUrl = configuration.unitURL {
            unitWebView.load(URLRequest(url:unitUrl))
        }
        
    }
    
    /// Refresh unit content
    public override func refreshContent() {
        // should be implemented later.
    }
    
    /// Reload webView
    public func reload() {
        if let unitUrl = configuration.unitURL {
            self.unitWebView.load(URLRequest(url:unitUrl))
        }
    }
    
    public func stop() {
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.pause,
                           to: self.unitWebView)
    }
    
    public func resume() {
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.resume,
                           to: self.unitWebView)
    }
    
    public func restart() {
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.restart,
                           to: self.unitWebView)
    }

    deinit {
        hide()
        destroy()
    }
}

// MARK: - Override internal APIs
@available(iOS 11.0, *)
extension APEUnitView {

    override func orientationDidChangeNotification() {}

    override func open(url: URL, type: APEViewNavigationType) {
        // wait for shouldHandleURL callback
        let shouldHandleURL: Void? = self.delegate?.unitView?(self, shouldHandleURL: url, type: type) {
            if !$0 {
                self.open(url)
            }
        }
        // check if the shouldHandleURL is implemented
        if shouldHandleURL == nil {
            self.open(url)
        }
    }

    override func didFailLoading(error: Error) {
        self.destroy()
        self.delegate?.unitView(self, didFailLoadingUnit: self.configuration.unitParams.id)
    }

    override func didFinishLoading() {
        self.delegate?.unitView(self, didFinishLoadingUnit: self.configuration.unitParams.id)
    }
    
    // Handle UserContentController Script Messages
    func publish(message: String) {
        guard let event = self.subscribedEvents.first(where: { message.contains($0) }) else { return }
        if self.subscribedEvents.contains(event) {
            self.delegate?.unitView?(self, didReciveEvent: event, message: message)
        }
    }
    
    func viewAbilityAssignment() {
        guard let containerVC = self.containerViewController, let view = self.containerView else {
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

    // Handle UserContentController Script Messages
    override func handleUserContentController(message: WKScriptMessage) {
        let messageName = message.name
        if message.webView?.hash == self.unitWebView.hash,
           messageName == Constants.Unit.proxy,
           let bodyString = message.body as? String {
            
            if !loadingState.isLoaded {
                loadingState.isLoaded = true
            }

            if bodyString.contains(Constants.Unit.resize),
               let dictionary = bodyString.dictionary {
                let height = dictionary.floatValue(for: Constants.Unit.height)
                let width = dictionary.floatValue(for: Constants.Unit.width)
                if CGFloat(height) != self.loadingState.height {
                    self.loadingState.height = CGFloat(height)
                    if loadingState.isLoaded {
                        self.update(height: height, width: width)
                    }
                }
            }

            if bodyString.contains(Constants.WebView.apesterAdsCompleted){
                self.delegate?.unitView(self, didCompleteAdsForUnit: self.configuration.unitParams.id)
            }
            
            if bodyString.contains(Constants.Monetization.initNativeAd),
               let dictionary = bodyString.dictionary {
                if let adMobProviderParams = AdMobProviderParams(from: dictionary) {
                    setupAdMobView(params: adMobProviderParams)
                }
                if let pubMaticProviderParams = PubMaticProviderParams(from: dictionary) {
                    setupPubMaticView(params: pubMaticProviderParams)
                }
            }
            
            if bodyString.contains(Constants.Monetization.initInUnit),
               let dictionary = bodyString.dictionary {
                if let pubMaticProviderParams = PubMaticProviderParams(from: dictionary) {
                    setupPubMaticView(params: pubMaticProviderParams)
                }
            }
            
            if bodyString.contains(Constants.Monetization.killInUnit),
               let adTypeStr = bodyString.dictionary?[Constants.Monetization.adType] as? String,
               let adType = PubMaticProviderParams.AdType(rawValue: adTypeStr) {
                removePubMaticView(of: adType)
            }
            
            if bodyString.contains(Constants.Unit.isReady), (configuration.autoFullscreen != nil) {
                DispatchQueue.main.async {
                    self.viewAbilityAssignment()
                    if !self.isDisplayed {
                        self.stop()
                    }
                }
            }
            
            if bodyString.contains(Constants.WebView.fullscreenOff) {
                configuration.setFullscreen(false)
                self.stop()
            }
        }

        if messageName == Constants.Unit.validateUnitViewVisibility {
            self.viewAbilityAssignment()
        }
        if let bodyString = message.body as? String {
            self.publish(message: bodyString)
        }
    }

    override func destroy() {
        self.unitWebView.configuration.userContentController
            .unregister(from: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibility])
    }
}

private extension APEUnitView {
    func constraint(for anchor: NSLayoutDimension, equalTo: NSLayoutDimension) -> NSLayoutConstraint {
        anchor.constraint(equalTo: equalTo)
    }

    func constraint(for anchor: NSLayoutDimension, equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        anchor.constraint(equalToConstant: constant)
    }

    func update(height: CGFloat, width: CGFloat) {
        
        guard configuration.autoFullscreen == nil else { return }
        
        // 1 - update the unitWebView height constraint
        self.unitWebViewHeightConstraint.flatMap { NSLayoutConstraint.deactivate([$0]) }
        unitWebViewHeightConstraint = unitWebView.heightAnchor.constraint(equalToConstant: height)
        unitWebViewHeightConstraint?.priority = .defaultHigh
        unitWebViewHeightConstraint?.isActive = true

        // 2 - update the unitWebView width constraint
        self.unitWebViewWidthConstraint.flatMap { NSLayoutConstraint.deactivate([$0]) }
        unitWebViewWidthConstraint = unitWebView.widthAnchor.constraint(equalToConstant: width)
        unitWebViewWidthConstraint?.priority = .defaultHigh
        unitWebViewWidthConstraint?.isActive = true

        if let containerView = self.containerView {
            // 3 - update the unit containerView height constraint
            containerView.constraints
                .first(where: { $0.firstAttribute == .height })
                .flatMap { NSLayoutConstraint.deactivate([$0]) }
            let unitWebViewHeightConstraint = constraint(for: containerView.heightAnchor, equalToConstant: height)
            unitWebViewHeightConstraint.priority = .defaultHigh
            unitWebViewHeightConstraint.isActive = true

            // 4 - update the unit containerView width constraint
            containerView.constraints
                .first(where: { $0.firstAttribute == .width })
                .flatMap { NSLayoutConstraint.deactivate([$0]) }
            let unitWebViewWidthConstraint = constraint(for: containerView.widthAnchor, equalToConstant: width)
            unitWebViewWidthConstraint.priority = .defaultHigh
            unitWebViewWidthConstraint.isActive = true
        }
        showPubMaticViews()
        
        // 5 - update the delegate about the new height
        self.delegate?.unitView(self, didUpdateHeight: height)
    }
}

// MARK:- PubMatic ADs
private extension APEUnitView {
    
    private func makePubMaticViewDelegate(adType: PubMaticProviderParams.AdType) -> PubMaticViewDelegate {
        PubMaticViewDelegate(adType: adType, containerViewController: containerViewController,
                             receiveAdSuccessCompletion: { [weak self] adType in
                                guard let self = self else { return }
                                if case .inUnit = adType {
                                    self.pubMaticViewCloseButton.isHidden = false
                                }
                                self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                         Constants.Monetization.playerMonImpression)
                             },
                             receiveAdErrorCompletion: { [weak self] adType, error in
                                guard let self = self else { return }
                                self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                         Constants.Monetization.playerMonLoadingImpressionFailed)
                                print(error?.localizedDescription ?? "")
                                if case .inUnit = adType {
                                    self.pubMaticViewCloseButton.isHidden = false
                                }
                                self.hidePubMaticView()
                             })
    }
    
    func setupPubMaticView(params: PubMaticProviderParams) {
        defer {
            showPubMaticViews()
        }
        var pubMaticView = self.pubMaticViews[params.adType]
        guard pubMaticView == nil else {
            pubMaticView?.forceRefresh()
            return
        }
        let appInfo = POBApplicationInfo()
        appInfo.domain = params.appDomain
        appInfo.storeURL = URL(string: params.appStoreUrl)!
        OpenWrapSDK.setApplicationInfo(appInfo)
        
        self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonLoadingPass)
        let adSizes = [POBAdSizeMake(params.adType.size.width, params.adType.size.height)].compactMap({ $0 })
        
        pubMaticView = POBBannerView(publisherId: params.publisherId,
                                     profileId: .init(value: params.profileId),
                                     adUnitId: params.adUnitId,
                                     adSizes: adSizes)
        
        pubMaticView?.request.testModeEnabled = params.testMode
        pubMaticView?.request.debug = params.debugLogs
        pubMaticView?.request.bidSummaryEnabled = params.bidSummaryLogs
        
        let pubMaticViewDelegate = pubMaticViewDelegates[params.adType] ?? makePubMaticViewDelegate(adType: params.adType)
        pubMaticView?.delegate = pubMaticViewDelegate
        pubMaticView?.loadAd()
        
        self.pubMaticViewDelegates[params.adType] = pubMaticViewDelegate
        self.pubMaticViews[params.adType] = pubMaticView
        
        guard  let timeInView = params.timeInView, pubMaticViewTimer == nil else { return }
        pubMaticViewTimer = Timer.scheduledTimer(withTimeInterval: Double(timeInView), repeats: false) { _ in
            self.hidePubMaticView()
        }
    }
    
    func removePubMaticView(of adType: PubMaticProviderParams.AdType) {
        pubMaticViews[adType]?.removeFromSuperview()
        pubMaticViews[adType] = nil
        guard pubMaticViewTimer != nil else { return }
        pubMaticViewCloseButton.removeFromSuperview()
        pubMaticViewTimer?.invalidate()
        pubMaticViewTimer = nil
    }
    
    @objc func hidePubMaticView() {
        removePubMaticView(of: .inUnit)
    }
    
    func showPubMaticViews() {
        self.pubMaticViews
            .forEach({ type, pubMaticView in
                guard let containerView = unitWebView else { return }
                containerView.addSubview(pubMaticView)
                containerView.bringSubviewToFront(pubMaticView)
                
                if case .inUnit = type {
                    if let bottomView = self.pubMaticViews[.bottom] {
                        containerView.bringSubviewToFront(bottomView)
                    }
                    self.pubMaticViewCloseButton.isHidden = true
                    containerView.addSubview(self.pubMaticViewCloseButton)
                    containerView.bringSubviewToFront(self.pubMaticViewCloseButton)
                }
                pubMaticView.translatesAutoresizingMaskIntoConstraints = false
                pubMaticView.removeConstraints(pubMaticView.constraints)
                NSLayoutConstraint.activate(pubMaticViewLayoutConstraints(pubMaticView, containerView: containerView, type: type))
            })
    }
    
    private func pubMaticViewLayoutConstraints(_ pubMaticView: POBBannerView, containerView: UIView, type: PubMaticProviderParams.AdType) -> [NSLayoutConstraint] {
        var constraints = [pubMaticView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0),
                           pubMaticView.widthAnchor.constraint(equalToConstant: type.size.width),
                           pubMaticView.heightAnchor.constraint(equalToConstant: type.size.height)]
        switch type {
        case .bottom:
            constraints += [pubMaticView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
        case .inUnit:
            constraints += [pubMaticView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
                            pubMaticViewCloseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor,
                                                                             constant: type.size.width/2 + 7),
                            pubMaticViewCloseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor,
                                                                             constant: -type.size.height/2 - 7)
            ]
        }
        return constraints
    }
}

// MARK:- Google ADs
private extension APEUnitView {
    
    private func makeGADViewDelegate() -> GADViewDelegate {
        GADViewDelegate(containerViewController: containerViewController,
                        receiveAdSuccessCompletion: { [weak self] in
                           guard let self = self else { return }
                           self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                    Constants.Monetization.playerMonImpression)
                        },
                        receiveAdErrorCompletion: { [weak self] error in
                           guard let self = self else { return }
                           self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                    Constants.Monetization.playerMonLoadingImpressionFailed)
                           print(error?.localizedDescription ?? "")
                        })
    }
    
    func setupAdMobView(params: AdMobProviderParams) {
        var gADView = gADViews[params]
        if gADView == nil {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonLoadingPass)
            gADView = GADBannerView(adSize: kGADAdSizeBanner)
            gADView?.translatesAutoresizingMaskIntoConstraints = false
            let gADViewDelegate = gADViewDelegates[params] ?? self.makeGADViewDelegate()
            gADView?.delegate = gADViewDelegate
            self.gADViewDelegates[params] = gADViewDelegate
            self.gADViews[params] = gADView
        }
        gADView?.adUnitID = params.adUnitId
        gADView?.load(GADRequest())
        self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonImpressionPending)
        showGADView()
    }
    
    func showGADView() {
        guard let containerView = unitWebView, let containerViewController = self.containerViewController else { return }
        gADViews.forEach { params, gADView in
            containerView.addSubview(gADView)
            gADView.rootViewController = containerViewController
            gADView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(gADViewLayoutConstraints(gADView, containerView: containerView, isCompanionVariant: params.isCompanionVariant))
        }
    }
    
    private func gADViewLayoutConstraints(_ gADView: GADBannerView, containerView: UIView, isCompanionVariant: Bool) -> [NSLayoutConstraint] {
        var constraints = [
            gADView.leadingAnchor.constraint(equalTo: unitWebView.leadingAnchor),
            gADView.trailingAnchor.constraint(equalTo: unitWebView.trailingAnchor)
        ]
        if isCompanionVariant {
            constraints.append(gADView.topAnchor.constraint(equalTo: unitWebView.bottomAnchor, constant: 0))
        } else {
            constraints.append(gADView.bottomAnchor.constraint(equalTo: unitWebView.bottomAnchor, constant: 0))
        }
        return constraints
    }
}
