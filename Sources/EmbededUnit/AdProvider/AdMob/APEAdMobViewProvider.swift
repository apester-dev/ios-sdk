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
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let adSize  = params.adType == .bottom ? GADAdSizeBanner : GADAdSizeMediumRectangle
        
        let gADView = GADBannerView(adSize: adSize)
        gADView.translatesAutoresizingMaskIntoConstraints = false
        gADView.rootViewController = containerViewController
        gADView.adUnitID = params.adUnitId
        gADView.delegate = banner.delegate as? GADBannerViewDelegate
        gADView.load(GADRequest())
        APELoggerService.shared.info("gADView::loadAd() - adType:\(params.adType), unitID: \(params.adUnitId)")
        
        banner.adContent = gADView
        
        provider.banner = { [banner] in banner }
        provider.type   = { [banner] in
            banner.monetization
        }
        provider.content = { [banner] in
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
                strongSelf.manualPostActionResize()
            },
            receiveAdErrorCompletion: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed)
                strongSelf.manualPostActionResize()
            })
        
        // showGADView
        if let provider = viewProvider {
            
            bannerViewProviders.append(provider)
            display(banner: provider, forAdType: params.adType)
        }
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass)
    }
}
