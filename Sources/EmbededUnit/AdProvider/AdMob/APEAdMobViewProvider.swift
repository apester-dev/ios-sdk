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
        
        banner.adContent = gADView
        
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
        provider.refresh  = {}
        return provider
    }
}

// MARK:- Google ADs
extension APEUnitView {
    
    func setupAdMobView(params: AdMobParams) {

        /// Step 01. Check if UnitView container has a containerViewController, A adViewProvider can be created / presented only if we have a valid container.
        guard let containerVC = containerViewController else {
            dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingImpressionFailed, for: params.adType, widget: false)
            return
        }

        /// Step 02. Locate a viewProvider instance if it exists in cache
        let provider: APEUnitView.BannerViewProvider? = bannerViewProviders.first(where: {
            switch $0.type() {
            case .pubMatic:
                return false
            case .adMob(let p):
                return p.adUnitId == params.adUnitId && p.adType == params.adType
            }
        })
        
        /// Step 03. if viewProvider instance is not found create it
        let viewProvider = provider.ape_isExist ? provider! : APEUnitView.BannerViewProvider.adMobProvider(
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
                APELoggerService.shared.info("gADView::loadAd() - adType:\(params.adType), unitID: \(params.adUnitId)")
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
        
        /// Step 05. - try to show GADView
        // guard display(banner: viewProvider) else { return }
            
        /// Step 06. Send analytics event if GADView was shown
        dispatchNativeAdEvent(named: Constants.Monetization.playerMonLoadingPass, for: params.adType, widget: true)
    }
}
