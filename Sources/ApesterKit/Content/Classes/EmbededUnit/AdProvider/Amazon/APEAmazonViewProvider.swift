//
//  APEAmazonViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//
import Foundation
import UIKit
///
///
///
import OpenWrapSDK
import OpenWrapHandlerDFP
import DTBiOSSDK
import OSLog

///
///
///
extension APEAdProvider {

    static func amazonProvider(
        params	                    : APEAmazonAdParameters,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText	        : String,
        inUnitBackgroundColor       : UIColor,
        GDPRConsent gdprString      : String?,
        onAdRemovalCompletion       : @escaping HandlerAdType,
        onAdRequestedCompletion     : @escaping HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping HandlerVoidType,
        receiveAdErrorCompletion    : @escaping HandlerErrorType
        
    ) -> APEAdProvider {

        let provider = APEAdProvider(
            monetization: APEMonetization.pubMatic(params: params),
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
