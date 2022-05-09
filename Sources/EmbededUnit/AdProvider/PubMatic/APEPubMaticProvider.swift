//
//  APEPubMaticProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import Foundation

extension APEUnitView.BannerViewProvider {
    
    static func pubMaticProvider(
        params: APEUnitView.PubMaticParams,
        adTitleLabelText: String,
        inUnitBackgroundColor: UIColor,
        containerViewController: UIViewController,
        onAdRemovalCompletion: @escaping ((APEUnitView.PubMaticParams.AdType) -> Void),
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.BannerViewProvider {
        var provider = APEUnitView.BannerViewProvider()
        let banner = APEPubMaticBannerView(
            params: params,
            adTitleLabelText: adTitleLabelText,
            inUnitBackgroundColor: inUnitBackgroundColor,
            containerViewController: containerViewController,
            onAdRemovalCompletion: onAdRemovalCompletion,
            receiveAdSuccessCompletion: receiveAdSuccessCompletion,
            receiveAdErrorCompletion: receiveAdErrorCompletion
        )
        provider.type = {
            .pubMatic(param: params)
        }
        provider.banner = {
            banner
        }
        provider.hide = {
            banner.hide()
        }
        
        provider.show = { containerView in
            banner.show(in: containerView)
        }
        provider.refresh = {
            banner.refresh()
        }
        return provider
    }
}

    // MARK:- PubMatic ADs
extension APEUnitView {
    
    func setupPubMaticView(params: PubMaticParams) {
        let adType: PubMaticParams.AdType = params.adType
        var bannerView = self.bannerViews.first(where: {
            switch $0.type() {
            case .pubMatic(let params):
                return params.adType == adType
            case .gad:
                return false
            }
        })
        if let pubMaticView = bannerView {
            pubMaticView.refresh()
            if let containerView = unitWebView, pubMaticView.banner().superview == nil {
                pubMaticView.show(containerView)
            }
            return
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
                self?.removePubMaticView(of: adType)
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
            if let containerView = unitWebView, bannerView.banner().superview == nil {
                bannerView.show(containerView)
            }
        }
        self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonLoadingPass)
    }
    
    func removePubMaticView(of adType: PubMaticParams.AdType) {
        guard let view = bannerViews.first(where: {
            switch $0.type() {
            case .pubMatic(let params):
                return params.adType == adType
            case .gad:
                return false
            }
        }) else { return }
        if let index = bannerViews.firstIndex(of: view) {
            bannerViews.remove(at: index)
        }
        view.hide()
    }
}
