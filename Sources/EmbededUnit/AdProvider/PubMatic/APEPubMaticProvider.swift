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
        onAdRemovalCompletion: @escaping ((APEUnitView.Monetization.AdType) -> Void),
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
        banner.adView = pubMaticView
        
        provider.type = { [banner] in
            banner.monetizationType
        }
        provider.banner = { [banner] in
            banner.adView
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
        let adType: Monetization.AdType = params.adType
        var bannerView = self.bannerViews.first(where: {
            switch $0.type() {
            case .pubMatic(let params):
                return params.adType == adType
            case .adMob, .none:
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
            self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                     Constants.Monetization.playerMonLoadingImpressionFailed)
            return
        }
        bannerView = .pubMaticProvider(
            params: params,
            adTitleLabelText: configuration.adTitleLabelText,
            inUnitBackgroundColor: configuration.adInUnitBackgroundColor,
            containerViewController: containerViewController,
            onAdRemovalCompletion: {  [weak self] adType in
                self?.removeAdView(of: adType)
            },
            receiveAdSuccessCompletion: { [weak self] in
                guard let self = self else { return }
                self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                         Constants.Monetization.playerMonImpression)
            },
            receiveAdErrorCompletion: { [weak self] error in
                guard let self = self else { return }
                self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                         Constants.Monetization.playerMonLoadingImpressionFailed)
            })
        
        if let bannerView = bannerView {
            self.bannerViews.append(bannerView)
            if let containerView = unitWebView, let banner = bannerView.banner(), banner.superview == nil {
                bannerView.show(containerView)
            }
        }
        self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonLoadingPass)
    }
}
