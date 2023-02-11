//
//  APEPubMaticProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import Foundation
import OpenWrapSDK
import OSLog

extension APEUnitView.BannerViewProvider {
    
    static func pubMaticProvider(
        params	                    : APEUnitView.PubMaticParams,
        adTitleLabelText	        : String,
        inUnitBackgroundColor       : UIColor,
        containerViewController     : UIViewController,
        onAdRemovalCompletion       : @escaping HandlerAdType,
        onAdRequestedCompletion     : @escaping HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping HandlerVoidType,
        receiveAdErrorCompletion    : @escaping HandlerErrorType
    ) -> APEUnitView.BannerViewProvider {
        
        var provider = APEUnitView.BannerViewProvider()
        
        let banner = APEBannerView(
            adTitleLabelText: adTitleLabelText,
            monetizationType: .pubMatic(params: params),
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView: params.timeInView,
            containerViewController: containerViewController,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        let adType  = params.adType
        let adSizes = [POBAdSizeMake(adType.width, adType.height)].compactMap({ $0 })
        
        let appInfo = POBApplicationInfo()
        appInfo.domain      = params.appDomain
        appInfo.storeURL    = URL(string: params.appStoreUrl)!
        
        OpenWrapSDK.setApplicationInfo(appInfo)
        
        banner.delegate = APEUnitView.PubMaticViewDelegate.init(
            containerViewController: containerViewController,
            receiveAdSuccessCompletion: {
                provider.bannerStatus = .success
                banner.onReceiveAdSuccess?()
                receiveAdSuccessCompletion()
            },
            receiveAdErrorCompletion: { [banner] error in
                provider.bannerStatus = .failure
                banner.onReceiveAdError?(error)
                receiveAdErrorCompletion(error)
            })
        
        let pubMaticView = POBBannerView(
            publisherId: params.publisherId,
            profileId: .init(value: params.profileId),
            adUnitId: params.adUnitId,
            adSizes: adSizes
        )
        
        pubMaticView?.request.debug             = params.debugLogs
        pubMaticView?.request.testModeEnabled   = params.testMode
        pubMaticView?.request.bidSummaryEnabled = params.bidSummaryLogs
        pubMaticView?.delegate = banner.delegate as? POBBannerViewDelegate
        pubMaticView?.loadAd()
        
        onAdRequestedCompletion()
        
        banner.adContent = pubMaticView
        
        provider.banner   = { [banner] in
            banner
        }
        provider.type     = { [banner] in
            banner.monetization
        }
        provider.content  = { [banner] in
            banner.adContent
        }
        provider.hide     = { [banner] in
            banner.hide()
        }
        provider.show     = { [banner] containerView in
            banner.show(in: containerView)
        }
        provider.refresh  = { [pubMaticView] in
            pubMaticView?.forceRefresh()
        }
        return provider
    }    
}

// MARK:- PubMatic ADs
extension APEUnitView {
    
    func setupPubMaticView(params: PubMaticParams) {
        
        /// Step 01. Check if UnitView conainer has a containerViewController, A adViewProvider can be created / presented only if we have a valid container.
        guard let containerVC = containerViewController else {
            dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, widget: false)
            return
        }

        /// Step 02. Locate a viewProvider instance if it exists in cache
        let provider: APEUnitView.BannerViewProvider? = bannerViewProviders.first(where: {
            switch $0.type() {
            case .adMob:
                return false
            case .pubMatic(let p):
                return p.adUnitId == params.adUnitId && p.adType == params.adType
            }
        })
        
        /// Step 03. if viewProvider instance is not found create it
        let viewProvider = provider.ape_isExist ? provider! : APEUnitView.BannerViewProvider.pubMaticProvider(
            params                  : params,
            adTitleLabelText        : configuration.adTitleLabelText,
            inUnitBackgroundColor   : configuration.adInUnitBackgroundColor,
            containerViewController : containerVC,
            onAdRemovalCompletion      : { [weak self] adsType in

                guard let strongSelf = self else { return }
                strongSelf.removeAdView(of: adsType)
            },
            onAdRequestedCompletion    : { [weak self] in

                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpressionPending, for: params.adType, widget: true)
                APELoggerService.shared.info("pubMaticView::loadAd() - adType:\(params.adType), unitID: \(params.adUnitId)")
            },
            receiveAdSuccessCompletion : { [weak self] in

                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpression, for: params.adType, widget: true)
                strongSelf.manualPostActionResize()
            },
            receiveAdErrorCompletion   : { [weak self] error in

                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, widget: true)
                strongSelf.manualPostActionResize()
            })
        
        /// Step 04. if viewProvider is not in cache, add it
        if !bannerViewProviders.contains(viewProvider) {
            bannerViewProviders.append(viewProvider)
        }

        // Added to enable debug mode handling
        if params.testMode && params.debugLogs {
            
            OpenWrapSDK.setLogLevel(POBSDKLogLevel.off)
            
            if let gdpr = configuration.gdprString {
                os_log("ApeSterSDK::-GDPR-String-: %{public}@", log: OSLog.ApesterSDK, type: .debug, gdpr)
                
                messageDispatcher.sendNativeGDPREvent(to: webContent, consent: gdpr)
            }
        }

        viewProvider.refresh()
        
        /// Step 05. - try to show GADView
        // guard display(banner: viewProvider) else { return }
        
        /// Step 06. Send analytics event if GADView was shown
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass, for: params.adType, widget: true)
    }
}
