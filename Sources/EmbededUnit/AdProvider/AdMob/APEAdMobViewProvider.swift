//
//  APEGADViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 06/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension APEUnitView.BannerViewProvider {
    
    static func adMobProvider(
        params: APEUnitView.AdMobParams,
        adTitleLabelText: String,
        inUnitBackgroundColor: UIColor,
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.BannerViewProvider {
        var provider = APEUnitView.BannerViewProvider()
        let banner = APEBannerView(
            adTitleLabelText: adTitleLabelText,
            monetizationType: .adMob(params: params),
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView: nil,
            containerViewController: containerViewController,
            onAdRemovalCompletion: nil
        )
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let gADView = GADBannerView(adSize: GADAdSizeBanner)
        gADView.translatesAutoresizingMaskIntoConstraints = false
        gADView.adUnitID = params.adUnitId
        gADView.load(GADRequest())
        
        banner.delegate = makeGADViewDelegate(
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
        gADView.delegate = banner.delegate as? GADBannerViewDelegate
        gADView.rootViewController = containerViewController
        banner.adView = gADView
        
        provider.type = { [banner] in
            banner.monetizationType
        }
        provider.banner = { [banner] in
            banner
        }
        provider.hide = { [banner] in
            banner.hide()
        }
        provider.show = { [banner] containerView in
            banner.show(in: containerView)
        }
        provider.refresh = {}
        return provider
    }
    
    static func makeGADViewDelegate(
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.AdMobViewDelegate {
        .init(containerViewController: containerViewController,
              receiveAdSuccessCompletion: receiveAdSuccessCompletion,
              receiveAdErrorCompletion: receiveAdErrorCompletion)
    }
}

// MARK:- Google ADs
extension APEUnitView {
    
    func setupAdMobView(params: AdMobParams) {
        let adUnitId = params.adUnitId
        var bannerView = self.bannerViews.first(where: {
            switch $0.type() {
            case .adMob(let params):
                return params.adUnitId == adUnitId
            case .pubMatic, .none:
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
        
        bannerView = .adMobProvider(
            params: params,
            adTitleLabelText: configuration.adTitleLabelText,
            inUnitBackgroundColor: configuration.adInUnitBackgroundColor,
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
