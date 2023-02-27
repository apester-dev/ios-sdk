//  APEUnitWebView.swift
//  ApesterKit
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
    public private(set) var unitWebView: WKWebView!
    
    // unitWebView Constraints
    private var unitWebViewHeightConstraint: NSLayoutConstraint?
    private var  unitWebViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - Data
    var bannerViews: [BannerViewProvider]
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
            messageDispatcher.dispatchAsync(Constants.WebView.setViewVisibilityStatus(isDisplayed), to: unitWebView)
        }
    }
    
    // MARK: - Initialization
    public init(configuration: APEUnitConfiguration) {
        
        self.bannerViews = []
        
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
        showAdViews()
    }
    
    func showAdViews() {
        bannerViews
            .forEach({ bannerView in
                
                if let containerView = unitWebView, let banner = bannerView.banner(), banner.superview == nil {
                    bannerView.show(containerView)
                }
        })
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
        bannerViews.forEach({ $0.hide() })
        bannerViews.removeAll()
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
        
        if messageName == Constants.Unit.proxy, message.webView?.hash == unitWebView.hash,
           let bodyString = message.body as? String ,
           let dictionary = bodyString.ape_dictionary
        {
            // print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
            // print("$$ - \(bodyString)")
            // print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
            
            if !loadingState.isLoaded {
                loadingState.isLoaded = true
            }
            
            if dictionary["type"] as? String == Constants.Unit.isReady
            {
                if !loadingState.isReady {
                    loadingState.isReady = true
                }
            }
            
            if dictionary["type"] as? String == Constants.Unit.resize 
            {
                let height = dictionary.ape_floatValue(for: Constants.Unit.height)
                let width  = dictionary.ape_floatValue(for: Constants.Unit.width)
                
                if CGFloat(height) != self.loadingState.height {
                    self.loadingState.height = CGFloat(height)
                    self.update(height: height, width: width)
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
                if let adTypeStr = bodyString.ape_dictionary?[Constants.Monetization.adType] as? String,
                   let adType = Monetization.AdType(rawValue: adTypeStr) {
                    removeAdView(of: adType)
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
            // case .companion: return "co"
            }
        }
        
        let provider = monProvider(for: adParamaters)
        
        messageDispatcher.sendNativeAdEvent(
            to: unitWebView,
            named: eventName,
            adType: adParamaters.description,
            ofType: adProviderType,
            provider: provider,
            inActive: inActiveDisplay
        )
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
        showAdViews()
        
        // 5 - update the delegate about the new height
        self.delegate?.unitView(self, didUpdateHeight: height)
    }
}

extension APEUnitView {
    
    struct BannerViewProvider: Equatable {
        
        enum Status {
            case pending
            case success
            case failure
        }
        typealias HandlerAdType     = (APEUnitView.Monetization) -> Void
        typealias HandlerVoidType   = () -> Void
        typealias HandlerErrorType  = (Error?) -> Void
        
        var type    : () -> APEUnitView.Monetization
        var banner  : () -> UIView?
        var refresh : () -> Void
        var show    : (_ contentView: UIView) -> Void
        var hide    : () -> Void
        var bannerStatus : Status
        
        init() {
            self.type     = { fatalError() }
            self.banner   = { fatalError() }
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
    
    func removeAdView(of adType: Monetization.AdType) {
        
        var viewProvider = bannerViews.first(where: {
            switch $0.type() {
            case .pubMatic(let params):
                return params.adType == adType
            case .adMob(let params):
                return params.adType == adType
            }
        })
        if let bannerView = viewProvider, let index = bannerViews.firstIndex(of: bannerView) {
            bannerViews.remove(at: index)
            bannerView.hide()
            viewProvider = nil
        }
    }
}
