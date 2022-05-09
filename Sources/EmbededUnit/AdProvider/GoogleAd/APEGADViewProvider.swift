//
//  APEGADViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 06/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation

extension APEUnitView.BannerViewProvider {
    
    static func gadProvider(
        params: APEUnitView.GADParams,
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.BannerViewProvider {
        var provider = APEUnitView.BannerViewProvider()
        let banner = APEGADBannerView(
            params: params,
            containerViewController: containerViewController,
            receiveAdSuccessCompletion: receiveAdSuccessCompletion,
            receiveAdErrorCompletion: receiveAdErrorCompletion
        )
        provider.type = {
            .gad(params: params)
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

// MARK:- Google ADs
extension APEUnitView {
    
    func setupGADView(params: GADParams) {
        let adUnitId = params.adUnitId
        var bannerView = self.bannerViews.first(where: {
            switch $0.type() {
            case .gad(let params):
                return params.adUnitId == adUnitId
            case .pubMatic:
                return false
            }
        })
        if let gadView = bannerView {
            if let containerView = unitWebView, gadView.banner().superview == nil {
                gadView.show(containerView)
            }
            return
        }
        guard let containerViewController = self.containerViewController else {
            self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                     Constants.Monetization.playerMonLoadingImpressionFailed)
            return
        }
        
        bannerView = .gadProvider(
            params: params,
            containerViewController: containerViewController,
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
        
            // showGADView
        if let bannerView = bannerView {
            self.bannerViews.append(bannerView)
            if let containerView = unitWebView, bannerView.banner().superview == nil {
                bannerView.show(containerView)
            }
        }
        self.messageDispatcher.sendNativeAdEvent(
            to: self.unitWebView, Constants.Monetization.playerMonLoadingPass
        )
    }
}
