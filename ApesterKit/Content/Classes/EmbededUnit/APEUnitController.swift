//
//  APEUnitController.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import WebKit
import UIKit
import Foundation

public typealias APEUnitView = APEUnitController
@objc(APEUnitView)
@objcMembers
public class APEUnitController : APEController
{
    // MARK: - API - Display
    public private(set) var displayView : APEDisplayView!
    public weak var unitWebView : WKWebView! { displayView.adUnit.webContent }
    
    private var   displayConstraintHeight: NSLayoutConstraint?
    private var   displayConstraintWidth : NSLayoutConstraint?
    private var containerConstraintHeight: NSLayoutConstraint?
    private var containerConstraintWidth : NSLayoutConstraint?
    
    private var   displayConstraints : [NSLayoutConstraint]
    {
        return [displayConstraintHeight, displayConstraintWidth].compactMap({ $0 })
    }
    private var containerConstraints : [NSLayoutConstraint]
    {
        return [containerConstraintHeight, containerConstraintWidth].compactMap({ $0 })
    }
    
    // MARK: - Data - internal
    internal var adBannerProviders: [APEAdProvider]
    
    // MARK: - Data - public
    public private(set) var  widgetHeight: CGFloat
    public private(set) var configuration: APEUnitConfiguration!
    public weak var delegate: APEUnitViewDelegate?
    
    // MARK: - Override Computed Logic
    public override var height: CGFloat
    {
        guard loadingState.isLoaded else {
            return .zero
        }
        return loadingState.height
    }
    
    public var identifier : String { configuration.unitParams.id }
    
    /// The view visibility status, update this property either when the view is visible or not.
    public override var isDisplayed: Bool
    {
        didSet {
            messageDispatcher.dispatchAsync(Constants.WebView.setViewVisibilityStatus(isDisplayed), to: unitWebView)
        }
    }
    
    
    // MARK: - Initialization
    public init(configuration: APEUnitConfiguration)
    {
        self.adBannerProviders = []
        self.widgetHeight = 0
        super.init(configuration.environment)
        
        self.configuration = configuration
        
        let eventsList = [
            Constants.Unit.proxy,
            Constants.Unit.validateUnitViewVisibility
        ]
        let options = WKWebView.Options(events: eventsList, contentBehavior: .never, delegate: self)
        
        self.displayView = APEDisplayView(frame: .zero)
        self.displayView.adUnit.webContent = WKWebView.make(with: options, params: configuration.parameters)
        self.refreshContent()
    }
    
    public override func display(in containerView: UIView, containerViewController: UIViewController)
    {
        super.display(in: containerView, containerViewController: containerViewController)
        
        // update unitWebView frame according to containerView bounds
        containerView.layoutIfNeeded()
        
        if (displayView.superview.ape_isExist && displayView.superview != containerView) {
            hide()
        }
        
        if (!displayView.superview.ape_isExist) {
            
            containerView.addSubview(displayView)
            
            // Apester Host
            var containerConstraints = [NSLayoutConstraint]()
            
            containerConstraints += containerView.ape_constraints(view: displayView, with: [
                equal(\.topAnchor) , equal(\.leadingAnchor), equal(\.trailingAnchor)
            ], priority: .required)
            
            let newConstraints = [
                containerView.ape_constraint(view: displayView, with: equal(\.heightAnchor), priority: .defaultLow),
                containerView.ape_constraint(view: displayView, with: equal(\.widthAnchor ), priority: .defaultLow)
            ]
            containerConstraints += newConstraints
            
            displayConstraints.forEach({ displayView.removeConstraint($0) })
            displayView.displayConstraintHeight = newConstraints.first
            displayView.displayConstraintWidth  = newConstraints.last
            
            displayConstraintHeight = displayView.displayConstraintHeight
            displayConstraintWidth  = displayView.displayConstraintWidth
            
            NSLayoutConstraint.activate(containerConstraints)
        }
        
        // show AD Views
        showAdViews()
    }
    
    private func showAdViews()
    {
        adBannerProviders.forEach { display(banner: $0) }
    }
    
    /// Remove the unit web view
    public override func hide()
    {
        displayView.removeFromSuperview()
    }
    
    public func setGdprString(_ gdprString: String)
    {
        configuration.gdprString = gdprString
        messageDispatcher.sendNativeGDPREvent(to: unitWebView, consent: gdprString)
    }
    
    /// Refresh unit content
    public override func refreshContent()
    {
        guard let unitUrl = configuration.unitURL else { return }
        unitWebView.load(URLRequest(url:unitUrl))
    }
    
    /// Reload webView
    public func reload()
    {
        // Stage 01 - Clear the providers data
        adBannerProviders.removeAll()
        
        // Stage 02 - clear the apds from display
        displayView.removeBannerViews() 
        
        // Stage 03 - clear logic flags, note: dont touch the height, as it will be update later
        loadingState.isLoaded = false
        loadingState.isReady  = false
        
        // Stage 04 - trigger a page refresh to relead the web page
        refreshContent()
    }
    
    public func stop()
    {
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.pause,
                           to: unitWebView)
    }
    
    public func resume()
    {
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.resume,
                           to: unitWebView)
    }
    
    public func restart()
    {
        self.messageDispatcher
            .dispatchAsync(Constants.WebView.restart,
                           to: unitWebView)
    }
    
    deinit
    {
        hide()
        destroy()
    }
}

// MARK: - Override internal APIs
@available(iOS 11.0, *)
extension APEUnitController
{
    override func orientationDidChangeNotification()
    {
        
    }
    
    override func open(url: URL, type: APEViewNavigationType)
    {
        // wait for shouldHandleURL callback
        let shouldHandleURL: Void? = self.delegate?.unitView?(self, shouldHandleURL: url, type: type) {
            
            if !$0 {
                self.open(url)
            }
        }
        
        // check if the shouldHandleURL is implemented
        if !shouldHandleURL.ape_isExist {
            self.open(url)
        }
    }
    
    override func didFailLoading(error: Error)
    {
        destroy()
        delegate?.unitView(self, didFailLoadingUnit: identifier)
    }
    
    override func didFinishLoading()
    {
        delegate?.unitView(self, didFinishLoadingUnit: identifier)
    }
    
    // Handle UserContentController Script Messages
    func publish(message: String)
    {
        guard let event = subscribedEvents.first(where: { message.contains($0) }) else { return }
        
        guard subscribedEvents.contains(event) else { return }
        delegate?.unitView?(self, didReciveEvent: event, message: message)
    }
    
    func viewAbilityAssignment()
    {
        guard let containerVC = containerViewController, let view = containerView else {
            self.isDisplayed = false
            return
        }
        
        if containerVC.view.ape_allSubviews.first(where: { $0 == view }).ape_isExist {
            let convertedCenterPoint = view.convert(view.center, to: containerVC.view)
            self.isDisplayed = containerVC.view.bounds.contains(convertedCenterPoint)
        } else {
            self.isDisplayed = false
        }
    }
    
    // Handle UserContentController Script Messages
    override func handleUserContentController(message: WKScriptMessage)
    {
        print(">>>> Payload message.name: \(String(describing: message.name))")
        print(">>>> Payload message.body: \(String(describing: message.body))")
        
        let messageName = message.name
        
        if messageName == Constants.Unit.proxy, message.webView?.hash == unitWebView.hash,
           let bodyString = message.body as? String ,
           let dictionary = bodyString.ape_dictionary
        {
            if !loadingState.isLoaded {
                loadingState.isLoaded = true
            }
            
            if dictionary["type"] as? String == Constants.Unit.isReady
            {
                if !loadingState.isReady {
                    loadingState.isReady = true
                }
            }
            
            if dictionary["type"] as? String == Constants.Unit.resize , let isFinalSize = dictionary["isFinalSizeForInApp"] as? Bool
            {
                let height = dictionary.ape_floatValue(for: Constants.Unit.height)
                let width  = dictionary.ape_floatValue(for: Constants.Unit.width)
                
                if CGFloat(height) != self.loadingState.height {
                    self.widgetHeight = height
                    self.loadingState.height = CGFloat(height)
                    self.update(height: height, width: width)
                }
                
                if isFinalSize {
                    self.widgetHeight = height
                    self.updateFinalDisplay(with: height)
                }
            }
            
            if dictionary["type"] as? String == Constants.WebView.apesterAdsCompleted
            {
                delegate?.unitView(self, didCompleteAdsForUnit: self.identifier)
            }
            
            if dictionary["type"] as? String == Constants.Monetization.initInUnit
            {
                print("||>>>> Payload: \(String(describing: dictionary))")
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
                print("||>>>> Payload: \(String(describing: dictionary))")
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
                   let adType    = APEAdType(rawValue: adTypeStr) {
                    removeAdView(of: adType)
                }
            }
            
            if dictionary.keys.contains(Constants.Unit.isReady) , (configuration.autoFullscreen.ape_isExist)
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
    
    override func destroy()
    {
        let scriptMessages = [
            Constants.Unit.proxy,
            Constants.Unit.validateUnitViewVisibility
        ]
        self.unitWebView
            .configuration
            .userContentController
            .unregister(from: scriptMessages)
    }
}

extension APEUnitController
{
    
    func dispatchNativeAdEvent(
        named eventName: String,
        for adParamaters: APEAdParameters,
        ofType adProviderType: APEAdProviderType,
        widget inActiveDisplay: Bool
    ) {
        APELoggerService.shared.info(eventName)
        
        func monProvider(for adParamaters: APEAdType) -> String
        {
            switch adParamaters {
            case .inUnit: return "da"
            case .bottom: return "da_bottom"
            case .companion: return "co"
            }
        }
        
        let provider = monProvider(for: adParamaters.type)
        
        messageDispatcher.sendNativeAdEvent(
            to: unitWebView,
            named: eventName,
            adType: adParamaters.type.description,
            ofType: adProviderType.description,
            provider: provider,
            inActive: inActiveDisplay
        )
    }
}

private extension APEUnitController
{
    func update(height: CGFloat, width: CGFloat) {
        print("||||======== update(height:width:) \(height), \(width)")
        // containerView?.constraints.forEach({ print("|||| \($0)") })
        // print("||||========")
        
        guard !configuration.autoFullscreen.ape_isExist else { return }
        
        let containerHeight = height + companionAdHeight;
        NSLayoutConstraint.deactivate(displayConstraints)
        displayConstraints.forEach({ displayView.removeConstraint($0) })
        
        // 1 - update the displayView height constraint
        let dhConstraint = equalValue(\.heightAnchor, to: containerHeight)
        displayView.displayConstraintHeight = displayView.ape_constraintSelf(with: dhConstraint, priority: .defaultHigh)
        displayConstraintHeight = displayView.displayConstraintHeight
        
        // 2 - update the displayView width constraint
        let dwConstraint = equalValue(\.widthAnchor , to: width)
        displayView.displayConstraintWidth = displayView.ape_constraintSelf(with: dwConstraint, priority: .defaultHigh)
        displayConstraintWidth = displayView.displayConstraintWidth
        NSLayoutConstraint.activate(displayConstraints)
        
        displayView.applyLayoutHeight(
            content: height,
            internal: internalBottomAdHeight,
            external: externalBottomAdHeight,
            companion: companionAdHeight
        )
        
        if let container = containerView {
            
            NSLayoutConstraint.deactivate(containerConstraints)
            containerConstraints.compactMap({ $0 }).forEach({
                displayView.removeConstraint($0)
            })
            // 3 - update the widget containerView height constraint
            let chConstraint = equalValue(\.heightAnchor, to: containerHeight)
            containerConstraintHeight = container.ape_constraintSelf(with: chConstraint, priority: .defaultHigh)
            
            // 4 - update the widget containerView width constraint
            let cwConstraint = equalValue(\.widthAnchor, to: width)
            containerConstraintWidth = container.ape_constraintSelf(with: cwConstraint, priority: .defaultHigh)
            
            NSLayoutConstraint.activate(containerConstraints)
        }
        
        // print("||||========containerView")
        // containerView?.constraints.forEach({ print("|||| \($0)") })
        // print("||||========displayView")
        // displayView?.constraints.forEach({ print("|||| \($0)") })
        print("||||======== update(height:width:)--end")
        
        showAdViews()
        
        loadingState.height = containerHeight
        
        // 5 - update the delegate about the new height
        delegate?.unitView(self, didUpdateHeight: containerHeight)
    }
}

internal extension APEUnitController
{
    private var internalBottomAdProvider : APEAdProvider? { adBannerProviders.first(where: { $0.isInternalBottom }) }
    private var externalBottomAdProvider : APEAdProvider? { adBannerProviders.first(where: { $0.isExternalBottom }) }
    private var      companionAdProvider : APEAdProvider? { adBannerProviders.first(where: { $0.isCompanion }) }
    
    private var internalBottomAdHeight : CGFloat {
        guard let p = internalBottomAdProvider else { return .zero }
        guard p.bannerStatus == .success       else { return .zero }
        return p.bannerHeight
    }
    private var externalBottomAdHeight : CGFloat {
        guard let p = externalBottomAdProvider else { return .zero }
        guard p.bannerStatus == .success       else { return .zero }
        return p.bannerHeight
    }
    private var      companionAdHeight : CGFloat {
        guard let p = companionAdProvider else { return .zero }
        guard p.bannerStatus == .success  else { return .zero }
        return p.bannerHeight
    }
    
    private func container(for adParamaters: APEMonetization?) -> APEContainerView?
    {
        guard let paramaters = adParamaters else { return nil }
        
        switch (paramaters.adType, paramaters.isCompanionVariant) {
        case (.inUnit   , _    ) : return displayView.adUnit.adContentMain
        case (.bottom   , false) : return displayView.adUnit.adContentBanner
        case (.bottom   , true ) : return displayView.adBottom
        case (.companion, _    ) : return displayView.adCompanion
        }
    }
    
    @discardableResult
    func display(banner provider: APEAdProvider) -> Bool
    {
        let monetization = provider.monetization
        
        guard let container = container(for: monetization) else { return false }
        guard let content   = provider.bannerContent()     else { return false }
        guard !content.superview.ape_isExist               else { return false }
        
        provider.refresh()
        
        switch (provider.monetization.adType, monetization.isCompanionVariant) {
        case (.inUnit   , _    ) : provider.show(container) // return false;
        case (.bottom   , true ) : provider.show(container) // return false;
        case (.bottom   , false) : provider.show(container) // return false;
        case (.companion, _    ) : provider.show(container) // return false;
        }
        return true
    }
    func removeAdView(of adType: APEAdType) {
        
        guard let provider = adBannerProviders.first(where: {
            switch $0.monetization {
            case .amazon  (let p): return p.type == adType
            case .adMob   (let p): return p.type == adType
            case .pubMatic(let p): return p.type == adType
            }
        }) else { return }
        
        removeAdView(for: provider)
    }
    
    func removeAdView(of monetization: APEMonetization?) {
        
        guard let monetization = monetization else { return }
        removeAdView(for: adBannerProviders.first { provider in
            return provider.monetization == monetization
        })
    }
    
    func removeAdView(for viewProvider: APEAdProvider?) {
        
        guard let provider = viewProvider else { return }
        guard let location = adBannerProviders.firstIndex(of: provider) else { return }
        adBannerProviders.remove(at: location)
        provider.bannerView.removeFromSuperview()
    }
}

internal extension APEUnitController {
    
    func manualPostActionResize() {
        // print("||||======== manualPostActionResize")
        updateFinalDisplay(with: widgetHeight)
        // print("||||======== manualPostActionResize--end")
    }
    
    func updateFinalDisplay(with height: CGFloat) {
        
        guard loadingState.isReady && loadingState.isLoaded else { return }
        guard !configuration.autoFullscreen.ape_isExist     else { return }
        print("||||======== updateFinalDisplay(with:) \(height)")
        
        let containerHeight = height + companionAdHeight;
        NSLayoutConstraint.deactivate([displayConstraintHeight].compactMap({ $0 }))
        [displayConstraintHeight].compactMap({ $0 }).forEach({
            displayView.removeConstraint($0)
        })
        displayView.displayConstraintHeight = displayView.ape_constraintSelf(
            with: equalValue(\.heightAnchor, to: containerHeight), priority: .defaultHigh
        )
        displayConstraintHeight = displayView.displayConstraintHeight
        NSLayoutConstraint.activate([displayConstraintHeight].compactMap({ $0 }))
        
        displayView.applyLayoutHeight(
            content: height,
            internal: internalBottomAdHeight,
            external: externalBottomAdHeight,
            companion: companionAdHeight
        )
        
        if let container = containerView
        {
            NSLayoutConstraint.deactivate([containerConstraintHeight].compactMap({ $0 }))
            [containerConstraintHeight].compactMap({ $0 }).forEach({
                container.removeConstraint($0)
            })
            containerConstraintHeight = container.ape_constraintSelf(
                with: equalValue(\.heightAnchor, to: containerHeight), priority: .defaultHigh
            )
            NSLayoutConstraint.activate([containerConstraintHeight].compactMap({ $0 }))
        }
        print("||||======== updateFinalDisplay(with:)--end")
        
        let isDifferentHeight = loadingState.height != containerHeight
        loadingState.height = containerHeight
        
        guard isDifferentHeight else { return }
        delegate?.unitView(self, didUpdateHeight: containerHeight)
    }
}
extension APEUnitController : APEAdProviderDelegate {
    weak var adPresentingViewController: UIViewController? {
        get { containerViewController }
    }
}
