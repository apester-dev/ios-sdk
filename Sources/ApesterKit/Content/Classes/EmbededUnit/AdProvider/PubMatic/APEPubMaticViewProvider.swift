//
//  APEPubMaticViewProvider.swift
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
///
///
///
extension APEAdProvider {
    
    static func pubMaticProvider(
        params	                    : APEPubMaticAdParameters,
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
        
        uniqePubMaticConfiguration(basedOn: params)
        uniqePubMaticGDPRConsent(gdprString)
        
        let banner = APEAdView(
            adTitleText          : adTitleLabelText,
            monetizationType     : provider.monetization,
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView           : nil,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
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
    
    private static func uniqePubMaticConfiguration(
        basedOn parameters: APEPubMaticAdParameters
    ) {
        let appInfo = POBApplicationInfo()
        appInfo.domain = parameters.appDomain
        if let appStoreUrl = URL(string: parameters.appStoreUrl) {
            appInfo.storeURL = appStoreUrl
        }
        
        OpenWrapSDK.setApplicationInfo(appInfo)
    }
    
    private static func uniqePubMaticGDPRConsent(
        _ gdprString: String?
    ) {
        guard let gdpr = gdprString else {
            OpenWrapSDK.setGDPREnabled(false); return
        }
        
        OpenWrapSDK.setGDPREnabled(true)
        OpenWrapSDK.setGDPRConsent(gdpr)
    }
}
