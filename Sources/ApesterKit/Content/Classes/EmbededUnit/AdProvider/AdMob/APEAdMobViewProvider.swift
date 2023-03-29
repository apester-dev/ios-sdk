//
//  APEAdMobViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 06/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//
import Foundation
import UIKit
///
///
///
import GoogleMobileAds
///
///
///
extension APEAdProvider {
    
    static func adMobProvider(
        params                      : APEAdMobAdParameters,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText            : String,
        inUnitBackgroundColor       : UIColor,
        GDPRConsent gdprString      : String?,
        onAdRemovalCompletion       : @escaping HandlerAdType,
        onAdRequestedCompletion     : @escaping HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping HandlerVoidType,
        receiveAdErrorCompletion    : @escaping HandlerErrorType
    ) -> APEAdProvider {
        
        let provider = APEAdProvider(
            monetization: APEMonetization.adMob(params: params),
            delegate: delegate
        )
        
        provider.nativeDelegate = APEAdMobDelegate.init(
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
        
        // TODO: ARKADI - move this to a diffrent location to make the system load faster
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // let adSizes = params.type.supportedSizes.compactMap {
        //     GADAdSizeFromCGSize($0.size)
        // }
        
        let adSize = params.type == .bottom ? APEAdSize.adSize320x50.size : APEAdSize.adSize300x250.size
        let nativeAdLibView : GADBannerView? = GADBannerView(adSize: GADAdSizeFromCGSize(adSize))
        if let nativeAdView = nativeAdLibView {
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            nativeAdView.adUnitID = params.identifier
            nativeAdView.delegate = provider.nativeDelegate as? GADBannerViewDelegate
        }
        
        banner.adContent       = nativeAdLibView
        provider.bannerView    = banner
        provider.bannerContent = { [weak banner] in banner?.adContent }
        provider.refresh       = { [weak banner] in banner?.adContent?.forceRefreshAd() }
        provider.hide          = { [weak banner] in banner?.hideAd()  }
        provider.show          = { [weak banner] containerDisplay in
            
            guard let adBanner = banner else { return }
            
            if let nativeAdView = nativeAdLibView , !nativeAdView.rootViewController.ape_isExist {
                nativeAdView.rootViewController = delegate.adPresentingViewController
                nativeAdView.load(GADRequest())
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
