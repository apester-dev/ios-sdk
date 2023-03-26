//
//  APEAmazonViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import UIKit
import Foundation
import OpenWrapSDK
import OpenWrapHandlerDFP
import OSLog


// MARK:- Amazon ADs
extension APEUnitController {

    private func dispatchAmazonEvent(
        named eventName: String,
        for adParamaters: APEAdParameters,
        widget inActiveDisplay: Bool
    ) {
        dispatchNativeAdEvent(named: eventName, for: adParamaters, ofType: APEAdProviderType.amazon, widget: inActiveDisplay)
    }

    func setupAmazonView(params: APEAmazonAdParameters) {

        // /// Step 01. Check if UnitView container has a containerViewController,
        // /// A adViewProvider can be created / presented only if we have a valid container.
        // guard let containerVC = containerViewController else {
        //
        //     let name = Constants.Analytics.playerMonLoadingImpressionFailed
        //     dispatchAmazonEvent(named: name, for: params, widget: false)
        //     return
        // }
        
        /// Step 02. Locate a viewProvider instance if it exists in cache
        let provider: APEAdProvider? = adBannerProviders.first(where: {
            switch $0.monetization {
            case .adMob, .pubMatic:
                return false
            case .amazon(let p):
                return p.identifier == params.identifier && p.type == params.type
            }
        })
        
        /// Step 03. if viewProvider instance is not found create it
        let viewProvider = provider.ape_isExist ? provider! : APEAdProvider.amazonProvider(
            params                  : params,
            delegate                : self,
            adTitleLabelText        : configuration.adTitleLabelText,
            inUnitBackgroundColor   : configuration.adInUnitBackgroundColor,
            onAdRemovalCompletion      : { [weak self] adsType in
                self?.removeAdView(of: adsType.adType)
            },
            onAdRequestedCompletion    : { [weak self] in
                guard let self else { return }
                let name = Constants.Analytics.playerMonImpressionPending
                self.dispatchAmazonEvent(named: name, for: params, widget: true)
                APELoggerService.shared.info("amazonView::loadAd() - adType:\(params.type), unitID: \(params.identifier)")
            },
            receiveAdSuccessCompletion : { [weak self] in
                self?.dispatchAmazonEvent(named: Constants.Analytics.playerMonImpression, for: params, widget: true)
                self?.manualPostActionResize()
            },
            receiveAdErrorCompletion   : { [weak self] error in
                self?.dispatchAmazonEvent(named: Constants.Analytics.playerMonLoadingImpressionFailed, for: params, widget: true)
                self?.manualPostActionResize()
            })

        /// Step 04. if viewProvider is not in cache, add it
        if !adBannerProviders.contains(viewProvider) {
            adBannerProviders.append(viewProvider)
        }
        
        /// Step 05. Check if UnitView container has a containerViewController,
        /// A adViewProvider can be presented only if we have a valid container.
        guard containerViewController.ape_isExist else {

            let name = Constants.Analytics.playerMonLoadingImpressionFailed
            dispatchAmazonEvent(named: name, for: params, widget: false)
            return
        }

//        TODO: Check this later
//        // Added to enable debug mode handling
//        if params.testMode && params.debugLogs {
//
//            OpenWrapSDK.setLogLevel(POBSDKLogLevel.off)
//
//            if let gdpr = configuration.gdprString {
//                os_log("ApeSterSDK::-GDPR-String-: %{public}@", log: OSLog.ApesterSDK, type: .debug, gdpr)
//                messageDispatcher.sendNativeGDPREvent(to: unitWebView, consent: gdpr)
//            }
//        }
        
        /// Step 06. - try to show AmazonView
        guard display(banner: viewProvider) else { return }
        
        /// Step 07. Send analytics event if GADView was shown
        dispatchAmazonEvent(named: Constants.Analytics.playerMonLoadingPass, for: params, widget: true)
    }
}
extension APEAdProvider {

    static func amazonProvider(
        params	                    : APEAmazonAdParameters,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText	        : String,
        inUnitBackgroundColor       : UIColor,
        onAdRemovalCompletion       : @escaping HandlerAdType,
        onAdRequestedCompletion     : @escaping HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping HandlerVoidType,
        receiveAdErrorCompletion    : @escaping HandlerErrorType
    ) -> APEAdProvider {

        let provider = APEAdProvider(
            monetization: APEMonetization.amazon(params: params),
            delegate: delegate
        )
        
        provider.nativeDelegate = APEAmazonDelegate.init(
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
        //
        let nativeAdLibView: POBBannerView?
        //
        //let adSizes = params.type.supportedSizes
        //    .compactMap {
        //        switch $0 {
        //        case .adSize320x50:  return NSValueFromGADAdSize(GADAdSizeBanner)
        //        case .adSize300x250: return NSValueFromGADAdSize(GADAdSizeMediumRectangle)
        //        }
        //    }
        //
        //if let eventHandler = DFPBannerEventHandler(adUnitId: params.dfp_au_banner, andSizes: adSizes) {
        //    eventHandler.configBlock = { view , request, bid in
        //
        //    }
        //    nativeAdLibView = POBBannerView(
        //        publisherId: params.publisherId,
        //        profileId: .init(value: params.profileId),
        //        adUnitId: params.identifier,
        //        eventHandler: eventHandler
        //    )
        //} else {
        //    nativeAdLibView = POBBannerView(
        //        publisherId: params.publisherId,
        //        profileId: .init(value: params.profileId),
        //        adUnitId: params.identifier,
        //        adSizes: params.type.supportedSizes.compactMap { POBAdSizeMakeFromCGSize($0.size) }
        //    )
        //}
        //
        //if let nativeAdView = nativeAdLibView {
        //    nativeAdView.request.debug             = params.debugLogs
        //    nativeAdView.request.testModeEnabled   = params.testMode
        //    nativeAdView.request.bidSummaryEnabled = params.bidSummaryLogs
        //    nativeAdView.delegate = provider.nativeDelegate as? POBBannerViewDelegate
        //}
        //
        //banner.adContent       = nativeAdLibView
        provider.bannerView    = banner
        provider.bannerContent = { [weak banner] in banner?.adContent }
        provider.refresh       = { [weak banner] in banner?.adContent?.forceRefreshAd() }
        provider.hide          = { [weak banner] in banner?.hideAd()  }
        //provider.show          = { [weak banner] containerDisplay in
        //
        //    guard let adBanner = banner else { return }
        //
        //    if let nativeAdLibView {
        //        nativeAdLibView.loadAd()
        //        onAdRequestedCompletion()
        //    }
        //    if let nativeDelegate = provider.nativeDelegate {
        //        nativeDelegate.containerViewController = delegate.adPresentingViewController
        //    }
        //    adBanner.showAd(in: containerDisplay)
        //}
        return provider
    }
}
