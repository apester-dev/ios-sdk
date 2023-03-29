//
//  APEAdProviderStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import UIKit
///
///
///
@objc(APEAdProviderStrategy)
@objcMembers
public class APEAdProviderStrategy : NSObject , APEAdProviderStrategyProtocol
{
    // MARK: - Properties - Computed
    internal var strategyType : APEAdProviderType
    {
        fatalError("OVERRIDE ME")
    }
    
    // MARK: - Properties - Stored
    internal var unitController : APEUnitController
    
    // MARK: - Initialization
    @objc
    required public init(unitController: APEUnitController) {
        self.unitController = unitController
    }
    
    // MARK: -
    @objc
    @discardableResult
    public func setupAdProvider(basedOn dictionary: [String: Any]) -> Bool {
        return setupAdProvider(basedOn: dictionary, unitController: unitController)
    }
    
    @objc
    @discardableResult
    public func setupAdProvider(basedOn dictionary: [String: Any], unitController controller: APEUnitController) -> Bool {
        
        /// Step 01. Locate a viewProvider instance if it exists in cache
        guard let parameters = generateAdParameters(form: dictionary) else {
            return false
        }
        
        /// Step 02. Locate a viewProvider instance if it exists in cache
        let provider: APEAdProvider? = controller.adBannerProviders.first(where: {
            switch $0.monetization {
            case .amazon  (let p):
                return p.identifier == parameters.identifier && p.isVariant == parameters.isVariant && p.type == parameters.type
            case .pubMatic(let p):
                return p.identifier == parameters.identifier && p.isVariant == parameters.isVariant && p.type == parameters.type
            case .adMob   (let p):
                return p.identifier == parameters.identifier && p.isVariant == parameters.isVariant && p.type == parameters.type
            }
        })

        let strategy = strategyType
        
        /// Step 03. if viewProvider instance is not found create it
        let viewProvider = provider.ape_isExist ? provider! : createAdProvider(
            params                  : parameters,
            delegate                : controller,
            adTitleLabelText        : controller.configuration.adTitleLabelText,
            inUnitBackgroundColor   : controller.configuration.adInUnitBackgroundColor,
            GDPRConsent             : controller.configuration.gdprString,
            onAdRemovalCompletion      : { adsType in

                controller.removeAdView(of: adsType.adType)
            },
            onAdRequestedCompletion    : {

                APELoggerService.shared.info("Strategy Type: \(strategy) - adType:\(parameters.type), unitID: \(parameters.identifier)")
                
                let name = Constants.Analytics.playerMonImpressionPending
                controller.dispatchNativeAdEvent(named: name, for: parameters, ofType: strategy, widget: true)
            },
            receiveAdSuccessCompletion : {

                let name = Constants.Analytics.playerMonImpression
                controller.dispatchNativeAdEvent(named: name, for: parameters, ofType: strategy, widget: true)
                controller.manualPostActionResize()
            },
            receiveAdErrorCompletion   : { error in

                let name = Constants.Analytics.playerMonLoadingImpressionFailed
                controller.dispatchNativeAdEvent(named: name, for: parameters, ofType: strategy, widget: true)
                controller.manualPostActionResize()
            })
        
        /// Step 04. if viewProvider is not in cache, add it
        if !controller.adBannerProviders.contains(viewProvider) {
            controller.adBannerProviders.append(viewProvider)
        }
        
        /// Step 05. Check if UnitView container has a containerViewController, A adViewProvider can be presented only if we have a valid container.
        guard controller.containerViewController.ape_isExist else {

            let name = Constants.Analytics.playerMonLoadingImpressionFailed
            controller.dispatchNativeAdEvent(named: name, for: parameters, ofType: strategy, widget: false)
            return false
        }
        
        /// Step 06. - try to show GADView
        guard controller.display(banner: viewProvider) else {
            return false
        }

        /// Step 07. Send analytics event if GADView was shown
        let name = Constants.Analytics.playerMonLoadingPass
        controller.dispatchNativeAdEvent(named: name, for: parameters, ofType: strategy, widget: true)
        
        return true
    }
    
    // MARK: - utilities - internal
    internal func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        fatalError("OVERRIDE ME")
    }
    internal func createAdProvider(
        params                      : APEAdParameters,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText            : String,
        inUnitBackgroundColor       : UIColor,
        GDPRConsent gdprString      : String?,
        onAdRemovalCompletion       : @escaping APEAdProvider.HandlerAdType,
        onAdRequestedCompletion     : @escaping APEAdProvider.HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping APEAdProvider.HandlerVoidType,
        receiveAdErrorCompletion    : @escaping APEAdProvider.HandlerErrorType
    ) -> APEAdProvider {
        fatalError("OVERRIDE ME")
    }
}
