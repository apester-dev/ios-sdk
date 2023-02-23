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
        
        banner.adView = pubMaticView
        
        provider.type = { [banner] in
            banner.monetizationType
        }
        provider.banner   = { [banner] in
            banner
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
        let adType: Monetization.AdType = params.adType
        var bannerView = self.bannerViews.first(where: {
            switch $0.type() {
            case .pubMatic(let params):
                return params.adType == adType
            case .adMob:
                return false
            }
        })
        if let bannerView = bannerView {
            bannerView.refresh()
            if let containerView = unitWebView, let banner = bannerView.banner(), banner.superview == nil {
                bannerView.show(containerView)
                return
            }
        }
        
        guard let containerViewController = self.containerViewController else {
            dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, ofType: APEUnitView.AdProvider.adMob, widget: false)
            return
        }
        bannerView = .pubMaticProvider(
            params: params,
            adTitleLabelText: configuration.adTitleLabelText,
            inUnitBackgroundColor: configuration.adInUnitBackgroundColor,
            containerViewController: containerViewController,
            onAdRemovalCompletion: {  [weak self] adsType in
                
                guard let strongSelf = self else { return }
                strongSelf.removeAdView(of: adsType.adType)
            },
            onAdRequestedCompletion    : { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpressionPending, for: params.adType, ofType: APEUnitView.AdProvider.pubmatic, widget: true)
                APELoggerService.shared.info("pubMaticView::loadAd() - adType:\(params.adType), unitID: \(params.adUnitId)")
            },
            receiveAdSuccessCompletion : { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpression, for: params.adType, ofType: APEUnitView.AdProvider.pubmatic, widget: true)
            },
            receiveAdErrorCompletion: { [weak self] error in
                
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, ofType: APEUnitView.AdProvider.pubmatic, widget: true)
            })
        
        if let bannerView = bannerView {
            self.bannerViews.append(bannerView)
            if let containerView = unitWebView, let banner = bannerView.banner(), banner.superview == nil {
                bannerView.show(containerView)
            }
        }
        
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass, for: params.adType, ofType: APEUnitView.AdProvider.pubmatic, widget: true)
    }
}
