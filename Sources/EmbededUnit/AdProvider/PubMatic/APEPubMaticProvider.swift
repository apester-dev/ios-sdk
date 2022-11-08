//
//  APEPubMaticProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import Foundation
import OpenWrapSDK

extension APEUnitView.BannerViewProvider {
    
    static func pubMaticProvider(
        params: APEUnitView.PubMaticParams,
        adTitleLabelText: String,
        inUnitBackgroundColor: UIColor,
        containerViewController: UIViewController,
        onAdRemovalCompletion: @escaping ((APEUnitView.Monetization) -> Void),
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
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
        
        let adType: APEUnitView.Monetization.AdType = params.adType
        
        let adSizes = [POBAdSizeMake(adType.size.width, adType.size.height)].compactMap({ $0 })
        
        let appInfo = POBApplicationInfo()
        appInfo.domain = params.appDomain
        appInfo.storeURL = URL(string: params.appStoreUrl)!
        OpenWrapSDK.setApplicationInfo(appInfo)
        
        OpenWrapSDK.setLogLevel(POBSDKLogLevel.all)
        
        let pubMaticView = POBBannerView(publisherId: params.publisherId,
                                         profileId: .init(value: params.profileId),
                                         adUnitId: params.adUnitId,
                                         adSizes: adSizes)
        
        pubMaticView?.request.testModeEnabled = params.testMode
        pubMaticView?.request.debug = params.debugLogs
        pubMaticView?.request.bidSummaryEnabled = params.bidSummaryLogs
        pubMaticView?.loadAd()
        banner.delegate = makePubMaticViewDelegate(
            adType: adType,
            containerViewController: containerViewController,
            receiveAdSuccessCompletion: {
                banner.onReceiveAdSuccess?()
                receiveAdSuccessCompletion()
            },
            receiveAdErrorCompletion: { [banner] error in
                banner.onReceiveAdError?(error)
                receiveAdErrorCompletion(error)
            }
        )
        pubMaticView?.delegate = banner.delegate as? POBBannerViewDelegate
        banner.adContent = pubMaticView
        
        provider.type = { [banner] in
            banner.monetization
        }
        provider.banner = { [banner] in
            banner.adContent
        }
        provider.hide = { [banner] in
            banner.hide()
        }
        provider.show = { [banner] containerView in
            banner.show(in: containerView)
        }
        provider.refresh = { [pubMaticView] in
            pubMaticView?.forceRefresh()
        }
        return provider
    }
    
    static func makePubMaticViewDelegate(
        adType: APEUnitView.Monetization.AdType,
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.PubMaticViewDelegate {
        .init(
            containerViewController: containerViewController,
            receiveAdSuccessCompletion: receiveAdSuccessCompletion,
            receiveAdErrorCompletion: receiveAdErrorCompletion
        )
    }
    
}

// MARK:- PubMatic ADs
extension APEUnitView {
    
    func setupPubMaticView(params: PubMaticParams) {
        
        let adType   = params.adType
        let adUnitId = params.adUnitId
        
        var viewProvider = bannerViewProviders.first(where: {
            switch $0.type() {
            case .adMob, .none:
                return false
            case .pubMatic(let params):
                return params.adUnitId == adUnitId && params.adType == adType
            }
        })
        
        if let provider = viewProvider {
            
            provider.refresh()
            display(banner: provider, forAdType: params.adType)
            return
        }
        
        guard let containerVC = containerViewController else {
            dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed)
            return
        }
        
        viewProvider = .pubMaticProvider(
            params: params,
            adTitleLabelText: configuration.adTitleLabelText,
            inUnitBackgroundColor: configuration.adInUnitBackgroundColor,
            containerViewController: containerVC,
            onAdRemovalCompletion: {  [weak self] adType in
                self?.removeAdView(of: adType)
            },
            receiveAdSuccessCompletion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpression)
            },
            receiveAdErrorCompletion: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed)
            })
        
        if let provider = viewProvider {
            
            bannerViewProviders.append(provider)
            display(banner: provider, forAdType: params.adType)
        }
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass)
    }
}