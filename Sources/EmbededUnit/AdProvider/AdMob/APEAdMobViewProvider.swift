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
        onAdRemovalCompletion: @escaping ((APEUnitView.Monetization) -> Void),
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
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let gADView = GADBannerView(adSize: (params.adType == .bottom) ? GADAdSizeBanner : GADAdSizeMediumRectangle)
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
        banner.adContent = gADView
        
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
        
        let adType   = params.adType
        let adUnitId = params.adUnitId
        
        var viewProvider = bannerViewProviders.first(where: {
            switch $0.type() {
            case .pubMatic, .none:
                return false
            case .adMob(let params):
                return params.adUnitId == adUnitId && params.adType == adType
            }
        })
        
        if let provider = viewProvider {
            
            display(banner: provider, forAdType: params.adType)
            return
        }
        
        guard let containerVC = containerViewController else {
            dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed)
            return
        }
        
        viewProvider = .adMobProvider(
            params: params,
            adTitleLabelText: configuration.adTitleLabelText,
            inUnitBackgroundColor: configuration.adInUnitBackgroundColor,
            containerViewController: containerVC, onAdRemovalCompletion: { [weak self] adType in
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
        
        // showGADView
        if let provider = viewProvider {
            
            bannerViewProviders.append(provider)
            display(banner: provider, forAdType: params.adType)
        }
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass)
    }
}
