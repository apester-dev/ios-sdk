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
        params                      : APEUnitView.AdMobParams,
        adTitleLabelText            : String,
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
            monetizationType: .adMob(params: params),
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView: nil,
            containerViewController: containerViewController,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        banner.delegate = APEUnitView.AdMobViewDelegate.init(
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
            }
        )
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let adSize  = params.adType == .bottom ? GADAdSizeBanner : GADAdSizeMediumRectangle
        
        let gADView = GADBannerView(adSize: adSize)
        gADView.translatesAutoresizingMaskIntoConstraints = false
        gADView.rootViewController = containerViewController
        gADView.adUnitID = params.adUnitId
        gADView.delegate = banner.delegate as? GADBannerViewDelegate
        gADView.load(GADRequest())
        
        onAdRequestedCompletion()
        
        banner.adView = gADView
        
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
            case .pubMatic:
                return false
            }
        })
        if let bannerView = bannerView {
            if let containerView = unitWebView, let banner = bannerView.banner(), banner.superview == nil {
                bannerView.show(containerView)
            }
            return
        }
        guard let containerViewController = self.containerViewController else {
            dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, ofType: APEUnitView.AdProvider.adMob, widget: false)
            return
        }
        
        bannerView = .adMobProvider(
            params: params,
            adTitleLabelText: configuration.adTitleLabelText,
            inUnitBackgroundColor: configuration.adInUnitBackgroundColor,
            containerViewController: containerViewController,
            onAdRemovalCompletion: { [weak self] adsType in
                guard let strongSelf = self else { return }
                strongSelf.removeAdView(of: adsType.adType)
            },
            onAdRequestedCompletion    : { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpressionPending, for: params.adType, ofType: APEUnitView.AdProvider.adMob, widget: true)
                APELoggerService.shared.info("gADView::loadAd() - adType:\(params.adType), unitID: \(params.adUnitId)")
            },
            receiveAdSuccessCompletion : { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonImpression, for: params.adType, ofType: APEUnitView.AdProvider.adMob, widget: true)
            },
            receiveAdErrorCompletion   : { [weak self] error in
                
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, ofType: APEUnitView.AdProvider.adMob, widget: true)
                
            })
        
            // showGADView
        if let bannerView = bannerView {
            self.bannerViews.append(bannerView)
            if let containerView = unitWebView, let banner = bannerView.banner(), banner.superview == nil {
                bannerView.show(containerView)
            }
        }
        
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass, for: params.adType, ofType: APEUnitView.AdProvider.adMob, widget: true)
    }
}
