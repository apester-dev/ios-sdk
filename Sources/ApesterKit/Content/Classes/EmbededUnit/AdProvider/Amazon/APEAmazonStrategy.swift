//
//  APEAmazonStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import UIKit
import OSLog
///
///
///
import OpenWrapSDK
import OpenWrapHandlerDFP
import DTBiOSSDK
///
///
///
@objc(APEAmazonStrategy)
@objcMembers
final public class APEAmazonStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.amazon
    }
    
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEAmazonAdParameters.init(from: dictionary)
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
        
        let parameters = params as! APEAmazonAdParameters

        let provider = APEAdProvider(
            monetization: APEMonetization.pubMatic(params: parameters),
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
        
        uniqePubMaticConfiguration(basedOn: parameters)
        
        let banner = APEAdView(
            adTitleText          : adTitleLabelText,
            monetizationType     : provider.monetization,
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView           : nil,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        let nativeAdLibView: POBBannerView?
        
        let adSize : APEAdSize = (params.type == .bottom) ? APEAdSize.adSize320x50 : APEAdSize.adSize300x250
        
        let adSizes = params.type.supportedSizes
            .compactMap {
                switch $0 {
                case .adSize320x50:  return NSValueFromGADAdSize(GADAdSizeBanner)
                case .adSize300x250: return NSValueFromGADAdSize(GADAdSizeMediumRectangle)
                }
            }
        
        
        if let eventHandler = DFPBannerEventHandler(adUnitId: parameters.dfp_au_banner, andSizes: adSizes) {
            
            eventHandler.configBlock = { view , request, bid in }
            
            nativeAdLibView = POBBannerView(
                publisherId: parameters.publisherId,
                profileId: .init(value: parameters.profileId),
                adUnitId: parameters.identifier,
                eventHandler: eventHandler
            )
            
        } else {
            nativeAdLibView = POBBannerView(
                publisherId: parameters.publisherId,
                profileId: .init(value: parameters.profileId),
                adUnitId: parameters.identifier,
                adSizes: parameters.type.supportedSizes.compactMap { POBAdSizeMakeFromCGSize($0.size) }
            )
        }
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
    
    private func uniqePubMaticConfiguration(
        basedOn parameters: APEAmazonAdParameters
    ) {
        let appInfo = POBApplicationInfo()
        appInfo.domain = parameters.appDomain
        if let appStoreUrl = URL(string: parameters.appStoreUrl) {
            appInfo.storeURL = appStoreUrl
        }
        
        OpenWrapSDK.setApplicationInfo(appInfo)
    }
    
    private func generatePOBBannerView(
        basedOn parameters: APEAmazonAdParameters
    ) -> POBBannerView? {
        let adSizes =  [NSValue]()
        if let eventHandler = DFPBannerEventHandler(adUnitId: parameters.dfp_au_banner, andSizes: adSizes) {
            
            eventHandler.configBlock = { view , request, bid in }
            
            return POBBannerView(
                publisherId: parameters.publisherId,
                profileId: .init(value: parameters.profileId),
                adUnitId: parameters.identifier,
                eventHandler: eventHandler
            )
            
        } else {
            return POBBannerView(
                publisherId: parameters.publisherId,
                profileId: .init(value: parameters.profileId),
                adUnitId: parameters.identifier,
                adSizes: parameters.type.supportedSizes.compactMap { POBAdSizeMakeFromCGSize($0.size) }
            )
        }
    }
}
