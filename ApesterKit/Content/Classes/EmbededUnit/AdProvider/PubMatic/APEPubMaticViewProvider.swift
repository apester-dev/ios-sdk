//
//  APEPubMaticViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import UIKit
import Foundation
import OpenWrapSDK
import OSLog


// MARK:- PubMatic ADs
extension APEUnitController {
    
    private func dispatchPubmaticEvent(
        named eventName: String,
        for adParamaters: APEAdParameters,
        widget inActiveDisplay: Bool
    ) {
        dispatchNativeAdEvent(named: eventName, for: adParamaters, ofType: APEAdProviderType.pubmatic, widget: inActiveDisplay)
    }
    
    func setupPubMaticView(params: PubMaticParams) {
        
        // /// Step 01. Check if UnitView container has a containerViewController,
        // /// A adViewProvider can be created / presented only if we have a valid container.
        // guard let containerVC = containerViewController else {
        //
        //     let name = Constants.Monetization.playerMonLoadingImpressionFailed
        //     dispatchPubmaticEvent(named: name, for: params, widget: false)
        //     return
        // }

        /// Step 02. Locate a viewProvider instance if it exists in cache
        let provider: APEAdProvider? = adBannerProviders.first(where: {
            switch $0.monetization {
            case .adMob:
                return false
            case .pubMatic(let p):
                return p.identifier == params.identifier && p.type == params.type
            }
        })
        
        /// Step 03. if viewProvider instance is not found create it
        let viewProvider = provider.ape_isExist ? provider! : APEAdProvider.pubMaticProvider(
            params                  : params,
            delegate                : self,
            adTitleLabelText        : configuration.adTitleLabelText,
            inUnitBackgroundColor   : configuration.adInUnitBackgroundColor,
            onAdRemovalCompletion      : { [weak self] adsType in
                
                guard let strongSelf = self else { return }
                strongSelf.removeAdView(of: adsType.adType)
            },
            onAdRequestedCompletion    : { [weak self] in
                
                guard let strongSelf = self else { return }
                let name = Constants.Monetization.playerMonImpressionPending
                strongSelf.dispatchPubmaticEvent(named: name, for: params, widget: true)
                APELoggerService.shared.info("pubMaticView::loadAd() - adType:\(params.type), unitID: \(params.identifier)")
            },
            receiveAdSuccessCompletion : { [weak self] in
                
                guard let strongSelf = self else { return }
                let name = Constants.Monetization.playerMonImpression
                strongSelf.dispatchPubmaticEvent(named: name, for: params, widget: true)
                strongSelf.manualPostActionResize()
            },
            receiveAdErrorCompletion   : { [weak self] error in
                
                guard let strongSelf = self else { return }
                let name = Constants.Monetization.playerMonLoadingImpressionFailed
                strongSelf.dispatchPubmaticEvent(named: name, for: params, widget: true)
                strongSelf.manualPostActionResize()
            })
        
        /// Step 04. if viewProvider is not in cache, add it
        if !adBannerProviders.contains(viewProvider) {
            adBannerProviders.append(viewProvider)
        }
        
        /// Step 05. Check if UnitView container has a containerViewController,
        /// A adViewProvider can be presented only if we have a valid container.
        guard containerViewController.ape_isExist else {
            
            let name = Constants.Monetization.playerMonLoadingImpressionFailed
            dispatchPubmaticEvent(named: name, for: params, widget: false)
            return
        }
        
        // Added to enable debug mode handling
        if params.testMode && params.debugLogs {
            
            OpenWrapSDK.setLogLevel(POBSDKLogLevel.off)
            
            if let gdpr = configuration.gdprString {
                os_log("ApeSterSDK::-GDPR-String-: %{public}@", log: OSLog.ApesterSDK, type: .debug, gdpr)
                messageDispatcher.sendNativeGDPREvent(to: unitWebView, consent: gdpr)
            }
        }
                
        /// Step 05. - try to show GADView
        guard display(banner: viewProvider) else { return }
        
        /// Step 06. Send analytics event if GADView was shown
        dispatchPubmaticEvent(named: Constants.Monetization.playerMonLoadingPass, for: params, widget: true)
    }
}
extension APEAdProvider {
    
    static func pubMaticProvider(
        params	                    : PubMaticParams,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText	        : String,
        inUnitBackgroundColor       : UIColor,
        onAdRemovalCompletion       : @escaping HandlerAdType,
        onAdRequestedCompletion     : @escaping HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping HandlerVoidType,
        receiveAdErrorCompletion    : @escaping HandlerErrorType
    ) -> APEAdProvider {
        
        let provider = APEAdProvider(
            monetization: APEMonetization.pubMatic(params: params),
            delegate: delegate
        )
        
        provider.nativeDelegate = APEPubMaticDelegate.init(
            container: nil,
            receiveAdSuccess: { [provider] in
                provider.statusSuccess()
                provider.bannerView.onReceiveAdSuccess()
                receiveAdSuccessCompletion()
            },
            receiveAdError: { [provider] mistake in
                provider.statusFailure()
                provider.bannerView.onReceiveAdError(mistake)
                receiveAdErrorCompletion(mistake)
            }
        )
        
        let banner = APEAdView(
            adTitleText          : adTitleLabelText,
            monetizationType     : provider.monetization,
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView           : nil,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        let appInfo = POBApplicationInfo()
        appInfo.domain      = params.appDomain
        appInfo.storeURL    = URL(string: params.appStoreUrl)!
        
        OpenWrapSDK.setApplicationInfo(appInfo)
        
        let adSizes = params.type.supportedSizes.compactMap {
            POBAdSizeMakeFromCGSize($0.size)
        }
        
        let nativeAdLibView = POBBannerView(
            publisherId: params.publisherId,
            profileId: .init(value: params.profileId),
            adUnitId: params.identifier,
            adSizes: adSizes
        )
        
        if let nativeAdView = nativeAdLibView {
            nativeAdView.request.debug             = params.debugLogs
            nativeAdView.request.testModeEnabled   = params.testMode
            nativeAdView.request.bidSummaryEnabled = params.bidSummaryLogs
            nativeAdView.delegate = provider.nativeDelegate as? POBBannerViewDelegate
        }
        
        banner.adContent       = nativeAdLibView
        provider.bannerView    = banner
        provider.bannerContent = { [weak banner] in banner?.adContent }
        provider.refresh       = { [weak banner] in banner?.adContent?.forceRefreshAd() }
        provider.hide          = { [weak banner] in banner?.hideAd()  }
        provider.show          = { [weak banner] containerDisplay in
            
            guard let adBanner = banner else { return }
            
            if let nativeAdView = nativeAdLibView {
                nativeAdView.loadAd()
                onAdRequestedCompletion()
            }
            if let nativeDelegate = provider.nativeDelegate {
                nativeDelegate.containerViewController = delegate.adPresentingViewController
            }
            adBanner.showAd(in: containerDisplay)
        }
        return provider
    }
}
