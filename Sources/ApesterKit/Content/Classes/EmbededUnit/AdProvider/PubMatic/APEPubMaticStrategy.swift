//
//  APEPubMaticStrategy.swift
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
///
///
///
@objc(APEPubMaticStrategy)
@objcMembers
final public class APEPubMaticStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.pubmatic
    }
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEPubMaticAdParameters.init(from: dictionary)
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
        
        let parameters = params as! APEPubMaticAdParameters
        
        publishGDPR(basedOn: parameters, GDPRConsent: gdprString, delegate: delegate)
        
        let provider = APEAdProvider(
            monetization: APEMonetization.pubMatic(params: parameters),
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
        
        uniqePubMaticConfiguration(basedOn: parameters)
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
            publisherId: parameters.publisherId,
            profileId: .init(value: parameters.profileId),
            adUnitId: params.identifier,
            adSizes: adSizes
        )
        
        if let nativeAdView = nativeAdLibView {
            nativeAdView.request.debug             = parameters.debugLogs
            nativeAdView.request.testModeEnabled   = parameters.testMode
            nativeAdView.request.bidSummaryEnabled = parameters.bidSummaryLogs
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
    
    private func publishGDPR(
        basedOn parameters    : APEPubMaticAdParameters,
        GDPRConsent gdprString: String?,
        delegate              : APEAdProviderDelegate
    ) {
        guard parameters.testMode  else { return }
        guard parameters.debugLogs else { return }
        
        guard let gdpr = gdprString else { return }
        os_log("ApeSterSDK::-GDPR-String-: %{public}@", log: OSLog.ApesterSDK, type: .debug, gdpr)
        delegate.sendNativeGDPREvent(with: gdpr)
    }
    
    private func uniqePubMaticConfiguration(
        basedOn parameters: APEPubMaticAdParameters
    ) {
        let appInfo = POBApplicationInfo()
        appInfo.domain = parameters.appDomain
        if let appStoreUrl = URL(string: parameters.appStoreUrl) {
            appInfo.storeURL = appStoreUrl
        }
        
        OpenWrapSDK.setApplicationInfo(appInfo)
    }
    
    private func uniqePubMaticGDPRConsent(
        _ gdprString: String?
    ) {
        guard let gdpr = gdprString else {
            OpenWrapSDK.setGDPREnabled(false); return
        }
        
        OpenWrapSDK.setGDPREnabled(true)
        OpenWrapSDK.setGDPRConsent(gdpr)
    }
}
