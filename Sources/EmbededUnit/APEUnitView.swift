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

@objcMembers
public class APEUnitView : APEView
{
    internal class AdProvider {
        internal static let adMob    : String = "adMob"
        internal static let pubmatic : String = "pubmatic"
        internal static let aniview  : String = "aniview_native"
    }
    
    // MARK: - API - Display
    public private(set) var displayView : APEDisplayView!
    internal weak var webContent : WKWebView! { displayView.adUnit.webContent }
    
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
    
    // MARK: - Initialization
    public init(configuration: APEUnitConfiguration) {
        
        self.bannerViewProviders = []
        
        super.init(configuration.environment)
        
        self.configuration = configuration
        let options = WKWebView.Options(events: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibility], contentBehavior: .never, delegate: self)
        
        self.displayView = APEDisplayView(frame: .zero)
        self.displayView.adUnit.webContent = WKWebView.make(with: options, params: configuration.parameters)
        self.refreshContent()
    }
    
    public override func display(in containerView: UIView, containerViewController: UIViewController) {
        super.display(in: containerView, containerViewController: containerViewController)
        
        // Apester Host
        var containerConstraint = [NSLayoutConstraint]()
        containerConstraint += containerView.ape_addSubview(displayView, with: [
            equal(\.topAnchor) , equal(\.leadingAnchor), equal(\.trailingAnchor)
        ])
        displayView.ape_anchor(view: containerView, with: [ greaterOrEqualValue(\.heightAnchor, \.heightAnchor) ])
        
        [displayView,containerView].forEach {
            $0?.setNeedsUpdateConstraints()
            $0?.setNeedsLayout()
            $0?.layoutIfNeeded()
        }
        
        reload()
    }
    
    /// Remove the unit web view
    public override func hide() {
        displayView.removeFromSuperview()
    }
    
    public func setGdprString(_ gdprString: String) {
        
        configuration.gdprString = gdprString
        
        reload()
        messageDispatcher.sendNativeGDPREvent(to: webContent, consent: gdprString)
    }
    
    /// Refresh unit content
    public override func refreshContent() {
        
        guard let unitUrl = configuration.unitURL else { return }
        webContent.load(URLRequest(url:unitUrl))
        updatePreviewDisplay(with: CGFloat(500.0))
    }
    
    /// Reload webView
    public func reload() {
        
        bannerViewProviders.forEach({ $0.hide() })
        bannerViewProviders.removeAll()
        displayView.removeBannerViews()
        
        loadingState.isLoaded = false
        loadingState.isReady  = false
        
        refreshContent()
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
        
        if messageName == Constants.Unit.proxy, message.webView?.hash == webContent.hash,
           let bodyString = message.body as? String ,
           let dictionary = bodyString.ape_dictionary
        {
            // print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
            // print("$$ - \(bodyString)")
            // print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
            
            if dictionary["type"] as? String == Constants.Unit.isReady
            {
                if !loadingState.isReady {
                    loadingState.isReady = true
                }
            }
            
            if dictionary["type"] as? String == Constants.Unit.resize , let isFinalSize = dictionary["isFinalSizeForInApp"] as? Bool
            {
                let height = dictionary.ape_floatValue(for: Constants.Unit.height)
                
                if !isFinalSize {
                    updatePreviewDisplay(with: height)
                } else {
                    if !loadingState.isLoaded {
                        loadingState.isLoaded = true
                        updateFinalDisplay(with: height)
                    }
                }
            }
            
            if dictionary["type"] as? String == Constants.WebView.apesterAdsCompleted
            {
                delegate?.unitView(self, didCompleteAdsForUnit: self.configuration.unitParams.id)
            }
            
            if dictionary["type"] as? String == Constants.Monetization.initInUnit
            {
                if let params = AdMobParams   (from: dictionary)
                {
                    setupAdMobView(params: params)
                }
                if let params = PubMaticParams(from: dictionary)
                {
                    setupPubMaticView(params: params)
                }
            }
            
            if dictionary["type"] as? String == Constants.Monetization.initNativeAd
            {
                if let params = AdMobParams   (from: dictionary)
                {
                    setupAdMobView(params: params)
                }
                if let params = PubMaticParams(from: dictionary)
                {
                    setupPubMaticView(params: params)
                }
            }
            
            if dictionary["type"] as? String == Constants.Monetization.killInUnit
            {
                if let p = bannerViewProviders.first(where: { $0.type().adType == .inUnit }) {
                    p.hide()
                    displayView.removeInUnitAd()
                }
            }
            
            if dictionary.keys.contains(Constants.Unit.isReady) , (configuration.autoFullscreen != nil)
            {
                DispatchQueue.main.async {
                    
                    self.viewAbilityAssignment()
                    if !self.isDisplayed {
                        self.stop()
                    }
                }
            }
            
            if dictionary.keys.contains(Constants.WebView.fullscreenOff)
            {
                configuration.setFullscreen(false)
                stop()
            }
        }
        
        if messageName == Constants.Unit.validateUnitViewVisibility {
            viewAbilityAssignment()
        }
        
        if let bodyString = message.body as? String
        {
            publish(message: bodyString)
        }
    }
    
    override func destroy() {
        self.webContent.configuration.userContentController
            .unregister(from: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibility])
    }
}
extension APEUnitView {
    func dispatchNativeAdEvent(
        named eventName: String,
        for adParamaters: Monetization.AdType,
        ofType adProviderType: String,
        widget inActiveDisplay: Bool
    ) {
        APELoggerService.shared.info(eventName)
        
        func monProvider(for adParamaters: Monetization.AdType) -> String
        {
            switch adParamaters {
            case .inUnit: return "da"
            case .bottom: return "da_bottom"
            case .companion: return "co"
            }
        }
        
        let provider = monProvider(for: adParamaters)
        
        messageDispatcher.sendNativeAdEvent(
            to: webContent,
            named: eventName,
            adType: adParamaters.description,
            ofType: adProviderType,
            provider: provider,
            inActive: inActiveDisplay
        )
    }
}

extension APEUnitView {
    
    struct BannerViewProvider : Equatable {
        
        enum Status {
            case pending
            case success
            case failure
        }
        typealias HandlerAdType     = (APEUnitView.Monetization) -> Void
        typealias HandlerVoidType   = () -> Void
        typealias HandlerErrorType  = (Error?) -> Void
        
        var type    : () -> APEUnitView.Monetization
        var banner  : () -> APEBannerView
        var content : () -> UIView?
        var refresh : () -> Void
        var show    : (_ contentView: APEContainerView) -> Void
        var hide    : () -> Void
        var bannerStatus : Status
        var bannerHeight : CGFloat {
            return banner().intrinsicContentSize.height
        }
        
        init() {
            self.type     = { fatalError() }
            self.banner   = { fatalError() }
            self.content  = { fatalError() }
            self.refresh  = { fatalError() }
            self.show     = { _ in fatalError() }
            self.hide     = { fatalError() }
            self.bannerStatus = .pending
        }
        
        static func == (lhs: APEUnitView.BannerViewProvider, rhs: APEUnitView.BannerViewProvider) -> Bool {
            
            let lt = lhs.type()
            let rt = rhs.type()
            
            return lt.adUnitId == rt.adUnitId && lt.adType == rt.adType && lt.isCompanionVariant == rt.isCompanionVariant
        }
    }
    
    func container(for adParamaters: APEUnitView.Monetization?) -> APEContainerView? {
        
        guard let paramaters = adParamaters else { return nil }
        
        switch (paramaters.adType, paramaters.isCompanionVariant) {
        case (.inUnit   , _    ) : return displayView.adUnit.adContentMain
        case (.bottom   , true ) : return displayView.adUnit.adContentBunner
        case (.bottom   , false) : return displayView.adBottom
        case (.companion, _    ) : return displayView.adCompanion
        }
    }
    
    @discardableResult
    func display(banner bannerView: APEUnitView.BannerViewProvider) -> Bool{
        guard let containerView = container(for: bannerView.type())      else { return false }
        guard let banner = bannerView.content(), banner.superview == nil else { return false }
        let monetization = bannerView.type()
        switch (monetization.adType, monetization.isCompanionVariant) {
        case (.inUnit   , _    ) : bannerView.show(containerView)
        case (.bottom   , true ) : bannerView.show(containerView)
        case (.bottom   , false) : bannerView.show(containerView)
        case (.companion, _    ) : bannerView.show(containerView)
        }
        return true
    }
    
    func updatePreviewDisplay(with height: CGFloat) {
        
        APELoggerService.shared.info("start---\(height)")
        DispatchQueue.main.async {
            self.loadingState.height = self.displayView.applyPreviewHeight(height)
        }
    }
    
    func updateFinalDisplay(with height: CGFloat) {
        
        guard loadingState.isReady && loadingState.isLoaded else { return }
        
        guard configuration.autoFullscreen == nil else { return }
        APELoggerService.shared.info("start---\(height)")
        
        let       inUnitHeight = CGFloat(height)
        var     inBottomHeight = CGFloat(0.0)
        var     adBottomHeight = CGFloat(0.0)
        var  adCompanionHeight = CGFloat(0.0)
        
        // Setup BannerView Height
        if let p = bannerViewProviders.first(where: { $0.type().adType == .bottom && $0.type().isCompanionVariant == true }) {
            inBottomHeight = p.bannerHeight
        }
        if let p = bannerViewProviders.first(where: { $0.type().adType == .bottom && $0.type().isCompanionVariant == false }) {
            adBottomHeight = p.bannerHeight
        }
        if let p = bannerViewProviders.first(where: { $0.type().adType == .companion }) {
            adCompanionHeight = p.bannerHeight
        }
        DispatchQueue.main.async {
            
            //print("$$ - inUnitHeight: \(inUnitHeight), inBottomHeight: \(inBottomHeight), adBottomHeight: \(adBottomHeight), adCompanionHeight: \(adCompanionHeight)")
            
            self.loadingState.height = self.displayView.applyLayoutHeight(
                inUnitHeight, inBottomHeight, adBottomHeight, adCompanionHeight
            )
            
            // Show BannerView ads content
            if let p = self.bannerViewProviders.first(where: { $0.type().adType == .inUnit }) {
                if p.bannerStatus == .success {
                    self.display(banner: p)
                }
            }
            if let p = self.bannerViewProviders.first(where: { $0.type().adType == .bottom && $0.type().isCompanionVariant == true }) {
                if p.bannerStatus != .failure {
                    self.display(banner: p)
                }
            }
            if let p = self.bannerViewProviders.first(where: { $0.type().adType == .bottom && $0.type().isCompanionVariant == false }) {
                if p.bannerStatus != .failure {
                    self.display(banner: p)
                }
            }
            if let p = self.bannerViewProviders.first(where: { $0.type().adType == .companion }) {
                if p.bannerStatus != .failure {
                    self.display(banner: p)
                }
            }
        }
        
        APELoggerService.shared.info("end")
        
        delegate?.unitView(self, didUpdateHeight: height)
    }
    
    func manualPostActionResize() {
        // APELoggerService.shared.info("SOME-SOME-SOME-SOME-SOME-SOME")
        updateFinalDisplay(with: displayView.adUnit.displayHeight ?? CGFloat(0.0) )
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
