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
        
        publishGDPR(basedOn: parameters, GDPRConsent: gdprString, delegate: delegate)
        
        let provider = APEAdProvider(
            monetization: APEMonetization.amazon(params: parameters),
            delegate: delegate
        )
        
        let nativeDelegate = APEAmazonDelegate.init(
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
        provider.nativeDelegate = nativeDelegate
        
        applyAmazonConfiguration(basedOn: parameters)
        applyPubMaticConfiguration(basedOn: parameters)
        applyPubMaticGDPRConsent(gdprString)
        
        let banner = APEAdView(
            adTitleText          : adTitleLabelText,
            monetizationType     : provider.monetization,
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView           : nil,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        let apesterAdSize = (parameters.type == .bottom) ? APEAdSize.adSize320x50 : APEAdSize.adSize300x250
        
        let adSizes = adSizeValue(basedOn: apesterAdSize)
        
        let nativeAdLibView : POBBannerView?
        if let eventHandler = DFPBannerEventHandler(adUnitId: parameters.dfp_au_banner, andSizes: adSizes) {
            
            nativeDelegate.biddingManager.register(Bidder: APEAmazonAdLoader(
                SlotUUID: parameters.amazon_slotID,
                apesterSize: apesterAdSize)
            )
            
            eventHandler.configBlock = { view , request, bid in
                print("eventHandler.configBlock")
                
                guard let delegate = provider.nativeDelegate as? APEAmazonDelegate else { return }
                    
                let partnerTargeting = delegate.biddingManager.retrivePartnerTargeting()
                let  customTargeting = request?.customTargeting as? NSMutableDictionary ?? NSMutableDictionary()
                
                for pair in partnerTargeting
                {
                    guard let information = pair.value as?  [String: String] else { continue }
                    customTargeting.addEntries(from: information)
                }
                request?.customTargeting = customTargeting as? [String: String]
                
                print("Successfully added targeting from all bidders")
            }
            
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
                adSizes: [apesterAdSize].compactMap { POBAdSizeMakeFromCGSize($0.size) }
            )
        }
        
        if let nativeAdView = nativeAdLibView {
            nativeAdView.request.debug             = parameters.debugLogs
            nativeAdView.request.testModeEnabled   = parameters.testMode
            nativeAdView.request.bidSummaryEnabled = parameters.bidSummaryLogs
            nativeAdView.delegate = provider.nativeDelegate as? POBBannerViewDelegate
            nativeAdView.bidEventDelegate = provider.nativeDelegate as? POBBidEventDelegate
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
                nativeDelegate.biddingManager.loadBids()
            }
            
            if let nativeAdLibView {
                nativeAdLibView.loadAd()
                onAdRequestedCompletion()
            }
            
            adBanner.showAd(in: containerDisplay)
        }
        return provider
    }
    
    private func applyAmazonConfiguration(
        basedOn parameters: APEAmazonAdParameters
    ) {
        let instance = DTBAds.sharedInstance()
        instance.setAppKey(parameters.amazon_key)
        instance.mraidPolicy = AUTO_DETECT_MRAID
        instance.setLogLevel(parameters.debugLogs ? DTBLogLevelAll : DTBLogLevelOff)
        instance.testMode = parameters.testMode
    }
    private func applyPubMaticConfiguration(
        basedOn parameters: APEAmazonAdParameters
    ) {
        let appInfo = POBApplicationInfo()
        appInfo.domain = parameters.appDomain
        if let appStoreUrl = URL(string: parameters.appStoreUrl) {
            appInfo.storeURL = appStoreUrl
        }
        
        OpenWrapSDK.setApplicationInfo(appInfo)
        OpenWrapSDK.setLogLevel(parameters.debugLogs ? POBSDKLogLevel.all : POBSDKLogLevel.off)
    }
    
    private func applyPubMaticGDPRConsent(
        _ gdprString: String?
    ) {
        guard let gdpr = gdprString else {
            OpenWrapSDK.setGDPREnabled(false); return
        }
        
        OpenWrapSDK.setGDPREnabled(true)
        OpenWrapSDK.setGDPRConsent(gdpr)
    }
    private func publishGDPR(
        basedOn parameters    : APEAmazonAdParameters,
        GDPRConsent gdprString: String?,
        delegate              : APEAdProviderDelegate
    ) {
        guard parameters.testMode  else { return }
        guard parameters.debugLogs else { return }
        
        guard let gdpr = gdprString else { return }
        os_log("ApeSterSDK::-GDPR-String-: %{public}@", log: OSLog.ApesterSDK, type: .debug, gdpr)
        delegate.sendNativeGDPREvent(with: gdpr)
    }
    
    private func adSizeValue(basedOn adSize: APEAdSize) -> [NSValue]
    {
        return [adSize].compactMap {
            switch $0 {
            case .adSize320x50:  return NSValueFromGADAdSize(GADAdSizeBanner)
            case .adSize300x250: return NSValueFromGADAdSize(GADAdSizeMediumRectangle)
            }
        }
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
