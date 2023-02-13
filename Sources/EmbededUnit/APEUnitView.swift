//
//  APEUnitWebView.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import WebKit
import UIKit
import Foundation

@objcMembers public class APEContainerView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
@objcMembers public   class APEDisplayView            : APEContainerView {}
@objcMembers internal class APEContainerViewInUnit    : APEContainerView {}
@objcMembers internal class APEContainerViewBottom    : APEContainerView {}
@objcMembers internal class APEContainerViewCompanion : APEContainerView {}

@objcMembers public class APEUnitView: APEView {
    
    // MARK: - API - Display
    public   private(set) var   displayView: APEDisplayView!
    internal private(set) var    webContent: WKWebView!
    internal private(set) var adMainContent: APEContainerViewInUnit!
    internal private(set) var adMainBottom : APEContainerViewBottom!
    internal private(set) var adCompanion  : APEContainerViewCompanion!
    
    private var displayViewConstraintHeight: NSLayoutConstraint?
    private var displayViewConstraintWidth : NSLayoutConstraint?
    
    private var webContentConstraintHeight : NSLayoutConstraint?
    private var webContentConstraintWidth  : NSLayoutConstraint?
    
    private var adMainBottomConstraintHeight: NSLayoutConstraint?
    private var  adCompanionConstraintHeight: NSLayoutConstraint?
    
    // MARK: - Data
    internal var bannerViewProviders: [BannerViewProvider]
    public private(set) var configuration: APEUnitConfiguration!
    public weak var delegate: APEUnitViewDelegate?
    
    // MARK: - Override Computed Logic
    
    public override var height: CGFloat {
        
        guard loadingState.isLoaded else {
            return .zero
        }
        return loadingState.height
    }
    
    /// The view visibility status, update this property either when the view is visible or not.
    public override var isDisplayed: Bool {
        didSet {
            messageDispatcher.dispatchAsync(Constants.WebView.setViewVisibilityStatus(isDisplayed), to: webContent)
        }
    }
    
    // MARK: - event API
    /// subscribe to events in order to observe the events messages data.
    /// for Example, subscribe to load and ready events by: `unitView.subscribe(["apester_interaction_loaded", "click_next"])`
    /// - Parameter events: the event names.
    public override func subscribe(events: [String]) {
        DispatchQueue.main.async { self.subscribedEvents = self.subscribedEvents.union(events) }
    }
    
    /// unsubscribe from events.
    /// - Parameter events: the event names.
    public override func unsubscribe(events: [String]) {
        DispatchQueue.main.async { self.subscribedEvents = self.subscribedEvents.subtracting(events) }
    }
    
    // MARK: - Initialization
    public init(configuration: APEUnitConfiguration) {
        
        self.bannerViewProviders = []
        
        super.init(configuration.environment)
        
        self.configuration = configuration
        let options = WKWebView.Options(events: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibility], contentBehavior: .never, delegate: self)
        
        self.displayView   = APEDisplayView(frame: .zero)
        self.webContent    = WKWebView.make(with: options, params: configuration.parameters)
        self.adMainContent = APEContainerViewInUnit(frame: .zero)
        self.adMainBottom  = APEContainerViewBottom(frame: .zero)
        self.adCompanion   = APEContainerViewCompanion(frame: .zero)
        
        displayView.addSubview(webContent)
        displayView.addSubview(adMainContent)
        displayView.addSubview(adMainBottom)
        displayView.addSubview(adCompanion)
        
        if let unitUrl = configuration.unitURL {
            webContent.load(URLRequest(url: unitUrl))
        }
    }
    
    public override func display(in containerView: UIView, containerViewController: UIViewController) {
        super.display(in: containerView, containerViewController: containerViewController)
        
        // webContent.backgroundColor = .red
        // adMainContent.backgroundColor = .green.withAlphaComponent(CGFloat(0.3))
        // adMainBottom.backgroundColor = .brown
        // adCompanion.backgroundColor = .cyan
        
        displayViewConstraintHeight = displayView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        displayViewConstraintHeight?.priority = .defaultLow
        
        displayViewConstraintWidth = displayView.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        displayViewConstraintWidth?.priority = .defaultLow
        
        containerView.layoutIfNeeded()
        
        var containerConstraint = [NSLayoutConstraint]()
        containerConstraint += containerView.ape_addSubview(displayView, with: [
            equal(\.topAnchor) , equal(\.leadingAnchor), equal(\.trailingAnchor)
        ])
        displayView.ape_anchor(view: containerView, with: [ greaterOrEqualValue(\.heightAnchor, \.heightAnchor) ], priority: .required)
        
        // webview
        displayView.ape_anchor(view: webContent, with: [ equal(\.topAnchor) , equal(\.leadingAnchor), equal(\.trailingAnchor) ])
        
        webContentConstraintHeight = webContent.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        webContentConstraintHeight?.priority = .defaultLow
        webContentConstraintHeight?.isActive = true
        
        webContentConstraintWidth = webContent.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        webContentConstraintWidth?.priority = .defaultLow
        webContentConstraintWidth?.isActive = true
        
        // cpm
        webContent.ape_anchor(view: adMainContent, with: UIView.anchorToContainer)
        
        // bottom
        webContent.ape_anchor(view: adMainBottom  , with: [ equal(\.leadingAnchor), equal(\.trailingAnchor)])
        adMainBottomConstraintHeight = webContent.ape_anchor(view: adMainBottom   , with: [ equal(\.bottomAnchor) ]).first
        
        // companion
        adCompanion.ape_anchor(view: webContent   , with: [ equal(\.leadingAnchor), equal(\.trailingAnchor) ])
        adCompanion.ape_anchor(view: adMainBottom , with: [ equal(\.bottomAnchor, \.topAnchor, constant: 0) ])
        displayView.ape_anchor(view: adCompanion  , with: [ equal(\.bottomAnchor) ] , priority: .required    )
        
        adCompanionConstraintHeight = adCompanion.heightAnchor.constraint(equalToConstant: adCompanion.intrinsicContentSize.height)
        adCompanionConstraintHeight?.priority = .defaultLow
        adCompanionConstraintHeight?.isActive = true
        
        [webContent,containerView].forEach {
            $0?.setNeedsLayout()
            $0?.layoutIfNeeded()
        }
        
        // show AD Views
        showAdViews()
    }
    
    func showAdViews() {
        
        bannerViewProviders.forEach {
            display(banner: $0, forAdType: $0.type()?.adType)
        }
    }
    
    /// Remove the unit web view
    public override func hide() {
        displayView.removeFromSuperview()
    }
    
    public func setGdprString(_ gdprString: String) {
        
        configuration.gdprString = gdprString
        
        if let unitUrl = configuration.unitURL { webContent.load(URLRequest(url:unitUrl)) }
    }
    
    /// Refresh unit content
    public override func refreshContent() {
        // should be implemented later.
    }
    
    /// Reload webView
    public func reload() {
        
        if let unitUrl = configuration.unitURL { webContent.load(URLRequest(url:unitUrl)) }
        bannerViewProviders.forEach({ $0.hide() })
        bannerViewProviders.removeAll()
    }
    
    public func stop() {
        messageDispatcher.dispatchAsync(Constants.WebView.pause, to: webContent)
    }
    
    public func resume() {
        messageDispatcher.dispatchAsync(Constants.WebView.resume, to: webContent)
    }
    
    public func restart() {
        messageDispatcher.dispatchAsync(Constants.WebView.restart, to: webContent)
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
        
        destroy()
        delegate?.unitView(self, didFailLoadingUnit: self.configuration.unitParams.id)
    }
    
    override func didFinishLoading() {
        
        delegate?.unitView(self, didFinishLoadingUnit: self.configuration.unitParams.id)
    }
    
    // Handle UserContentController Script Messages
    func publish(message: String) {
        
        guard let event = subscribedEvents.first(where: { message.contains($0) }) else { return }
        if subscribedEvents.contains(event) {
            delegate?.unitView?(self, didReciveEvent: event, message: message)
        }
    }
    
    func viewAbilityAssignment() {
        
        guard let containerVC = containerViewController, let view = containerView else {
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
        
        if messageName == Constants.Unit.proxy, message.webView?.hash == webContent.hash, let bodyString = message.body as? String {
            
            if !loadingState.isLoaded {
                loadingState.isLoaded = true
            }
            
            if bodyString.contains(Constants.Unit.resize), let dictionary = bodyString.ape_dictionary {
                
                let height = dictionary.ape_floatValue(for: Constants.Unit.height)
                let width  = dictionary.ape_floatValue(for: Constants.Unit.width)
                
                if CGFloat(height) != loadingState.height {
                    loadingState.height = CGFloat(height)
                    
                    if loadingState.isLoaded {
                        updateDisplaySize(with: height, width: width)
                    }
                }
            }
            
            if bodyString.contains(Constants.WebView.apesterAdsCompleted) {
                delegate?.unitView(self, didCompleteAdsForUnit: self.configuration.unitParams.id)
            }
            
            if bodyString.contains(Constants.Monetization.initNativeAd) , let dictionary = bodyString.ape_dictionary {
                
                if let params = AdMobParams   (from: dictionary) {
                    setupAdMobView(params: params)
                }
                if let params = PubMaticParams(from: dictionary) {
                    setupPubMaticView(params: params)
                }
            }
            
            if bodyString.contains(Constants.Monetization.initInUnit)  , let dictionary = bodyString.ape_dictionary {
                
                if let params = AdMobParams   (from: dictionary) {
                    setupAdMobView(params: params)
                }
                if let params = PubMaticParams(from: dictionary) {
                    setupPubMaticView(params: params)
                }
            }
            
            if bodyString.contains(Constants.Monetization.killInUnit)
            {
                removeAdView(for: bannerViewProviders.first { $0.type()?.adType == .inUnit })
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
                stop()
            }
        }
        
        if messageName == Constants.Unit.validateUnitViewVisibility {
            viewAbilityAssignment()
        }
        
        if let bodyString = message.body as? String {
            publish(message: bodyString)
        }
    }
    
    override func destroy() {
        self.webContent.configuration.userContentController
            .unregister(from: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibility])
    }
}

private extension APEUnitView {
    
    func updateDisplaySize(with height: CGFloat, width: CGFloat) {
        
        guard configuration.autoFullscreen == nil else { return }
        APELoggerService.shared.info("start")
        // 1 - update the unitWebView height constraint
        self.webContentConstraintHeight.flatMap { NSLayoutConstraint.deactivate([$0]) }
        webContentConstraintHeight = webContent.heightAnchor.constraint(equalToConstant: height)
        webContentConstraintHeight?.priority = .defaultHigh
        webContentConstraintHeight?.isActive = true
        
        // 2 - update the unitWebView width constraint
        self.webContentConstraintWidth.flatMap { NSLayoutConstraint.deactivate([$0]) }
        webContentConstraintWidth = webContent.widthAnchor.constraint(equalToConstant: width)
        webContentConstraintWidth?.priority = .defaultHigh
        webContentConstraintWidth?.isActive = true
        
        showAdViews()
        
        if containerView.ape_isExist, let p = provider(for: .bottom), p.type()?.isCompanionVariant == true {
            
            self.adMainBottomConstraintHeight.flatMap { NSLayoutConstraint.deactivate([$0]) }
            adMainBottomConstraintHeight = webContent.ape_anchor(view: adMainBottom, with: [
                equal(\.topAnchor, \.bottomAnchor, constant: 0)
            ]).first
        }
        
        displayView.setNeedsLayout()
        displayView.layoutIfNeeded()
        APELoggerService.shared.info("end")
        self.manualPostActionResize()
    }
}

extension APEUnitView {
    
    struct BannerViewProvider : Equatable {
        
        typealias HandlerAdType     = (APEUnitView.Monetization) -> Void
        typealias HandlerVoidType   = () -> Void
        typealias HandlerErrorType  = (Error?) -> Void
        
        var type    : () -> Monetization?
        var banner  : () -> APEBannerView?
        var content : () -> UIView?
        var refresh : () -> Void
        var show    : (_ contentView: UIView) -> Void
        var hide    : () -> Void
        
        init() {
            self.type    = { fatalError() }
            self.banner  = { fatalError() }
            self.content = { fatalError() }
            self.refresh = { fatalError() }
            self.show    = { _ in fatalError() }
            self.hide    = { fatalError() }
        }
        
        static func == (lhs: APEUnitView.BannerViewProvider, rhs: APEUnitView.BannerViewProvider) -> Bool {
            lhs.type() == rhs.type()
        }
    }
    
    func bannerViewProvider(for adType: Monetization.AdType, adUnitId: String) -> APEUnitView.BannerViewProvider? {
        
        return bannerViewProviders.first(where: {
            switch $0.type() {
            case .adMob   (let params): return params.adUnitId == adUnitId && params.adType == adType
            case .pubMatic(let params): return params.adUnitId == adUnitId && params.adType == adType
            case .none: return false
            }
        })
    }
    
    func container(for adType: APEUnitView.Monetization.AdType?) -> UIView? {
        
        switch adType {
        case .inUnit    : return adMainContent
        case .bottom    : return adMainBottom
        case .companion : return adCompanion
        case .none      : return nil
        }
    }
    
    func provider(for adType: APEUnitView.Monetization.AdType?) -> APEUnitView.BannerViewProvider? {
        return bannerViewProviders.first(where: { $0.type()?.adType == adType })
    }
    
    func display(banner bannerView: APEUnitView.BannerViewProvider, forAdType type: APEUnitView.Monetization.AdType?) {
        
        guard let containerView = container(for: type)         else { return }
        guard let b = bannerView.content(), b.superview == nil else { return }
        bannerView.show(containerView)
    }
    
    func manualPostActionResize() {
        APELoggerService.shared.info("start")
        var computedHeight = CGFloat(0.0)
        
        if containerView.ape_isExist {
            
            if let c = webContentConstraintHeight , c.isActive {
                computedHeight += c.constant
            }
            
            if let p = provider(for: .bottom), p.type()?.isCompanionVariant == true, let b = p.banner() {
                // add .bottom view isCompanionVariant == true into calculation
                computedHeight += b.intrinsicContentSize.height
            }
            if let p = provider(for: .companion), let b = p.banner() {
                // add .companion view into calculation
                computedHeight += b.intrinsicContentSize.height
            }
        }
        loadingState.height = CGFloat(computedHeight)
        APELoggerService.shared.info("end")
        delegate?.unitView(self, didUpdateHeight: computedHeight)
    }
    
    func dispatchNativeAdEvent(named eventName: String) {
        messageDispatcher.sendNativeAdEvent(to: webContent, eventName)
        APELoggerService.shared.info(eventName)
    }
    
    func removeAdView(of monetization: APEUnitView.Monetization?) {
        
        guard let monetization = monetization else { return }
        removeAdView(for: bannerViewProviders.first { provider in
            return provider.type() == monetization
        })
    }
    
    func removeAdView(for viewProvider: BannerViewProvider?) {
        
        if let bannerView = viewProvider, let location = bannerViewProviders.firstIndex(of: bannerView) {
            bannerViewProviders.remove(at: location)
            bannerView.hide()
        }
    }
}
