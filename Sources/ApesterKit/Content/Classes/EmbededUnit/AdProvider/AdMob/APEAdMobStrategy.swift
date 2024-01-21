//
//  APEAdMobStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
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
@objc(APEAdMobStrategy)
@objcMembers
final public class APEAdMobStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.adMob
    }
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEAdMobAdParameters.init(from: dictionary)
    }
    internal override func createAdProvider(
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
        
        let parameters = params as! APEAdMobAdParameters
        
        let provider = APEAdProvider(
            monetization: APEMonetization.adMob(params: parameters),
            delegate: delegate
        )
        
        provider.nativeDelegate = APEAdMobDelegate.init(
            adProvider      : provider,
            container       : nil,
            receiveAdSuccess: { [provider] in
                provider.statusSuccess()
                provider.bannerView.onReceiveAdSuccess()
                receiveAdSuccessCompletion()
            },
            receiveAdError  : { [provider] mistake in
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
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["92209F2A-5E96-47EB-B15B-DF3F18FBDDC4"]
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
            
            if let nativeDelegate = provider.nativeDelegate {
                nativeDelegate.containerViewController = delegate.adPresentingViewController
            }
            
            if let nativeAdView = nativeAdLibView , !nativeAdView.rootViewController.ape_isExist {
                nativeAdView.rootViewController = delegate.adPresentingViewController
                nativeAdView.load(GADRequest())
                onAdRequestedCompletion()
            }
            adBanner.showAd(in: containerDisplay)
        }
        return provider
    }
}
