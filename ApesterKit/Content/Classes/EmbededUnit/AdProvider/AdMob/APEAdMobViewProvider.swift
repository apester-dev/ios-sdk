//
//  APEAdMobViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 06/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

// MARK:- Google ADs
extension APEUnitController {
    
    private func dispatchAdMobEvent(
        named eventName: String,
        for adParamaters: APEAdParameters,
        widget inActiveDisplay: Bool
    ) {
        dispatchNativeAdEvent(named: eventName, for: adParamaters, ofType: APEAdProviderType.adMob, widget: inActiveDisplay)
    }
    
    func setupAdMobView(params: AdMobParams) {
        
        // /// Step 01. Check if UnitView container has a containerViewController, A adViewProvider can be created / presented only if we have a valid container.
        // guard let containerVC = containerViewController else {
        //
        //     let name = Constants.Monetization.playerMonLoadingImpressionFailed
        //     dispatchAdMobEvent(named: name, for: params, widget: false)
        //     return
        // }

        /// Step 02. Locate a viewProvider instance if it exists in cache
        let provider: APEAdProvider? = adBannerProviders.first(where: {
            switch $0.monetization {
            case .pubMatic:
                return false
            case .adMob(let p):
                return p.identifier == params.identifier && p.type == params.type
            }
        })

        /// Step 03. if viewProvider instance is not found create it
        let viewProvider = provider.ape_isExist ? provider! : APEAdProvider.adMobProvider(
            params                  : params,
            delegate                : self,
            adTitleLabelText        : configuration.adTitleLabelText,
            inUnitBackgroundColor   : configuration.adInUnitBackgroundColor,
            onAdRequestedCompletion    : { [weak self] in

                guard let strongSelf = self else { return }
                let name = Constants.Monetization.playerMonImpressionPending
                strongSelf.dispatchAdMobEvent(named: name, for: params, widget: true)
                
                APELoggerService.shared.info("gADView::loadAd() - adType:\(params.type), unitID: \(params.identifier)")
            },
            receiveAdSuccessCompletion : { [weak self] in

                guard let strongSelf = self else { return }
                let name = Constants.Monetization.playerMonImpression
                strongSelf.dispatchAdMobEvent(named: name, for: params, widget: true)
                strongSelf.manualPostActionResize()
            },
            receiveAdErrorCompletion   : { [weak self] error in

                guard let strongSelf = self else { return }
                let name = Constants.Monetization.playerMonLoadingImpressionFailed
                strongSelf.dispatchAdMobEvent(named: name, for: params, widget: true)
                strongSelf.manualPostActionResize()
            },
            onAdRemovalCompletion      : { [weak self] adsType in

                guard let strongSelf = self else { return }
                strongSelf.removeAdView(of: adsType.adType)
            })

        /// Step 04. if viewProvider is not in cache, add it
        if !adBannerProviders.contains(viewProvider) {
            adBannerProviders.append(viewProvider)
        }

        /// Step 05. Check if UnitView container has a containerViewController, A adViewProvider can be presented only if we have a valid container.
        guard containerViewController.ape_isExist else {
            
            let name = Constants.Monetization.playerMonLoadingImpressionFailed
            dispatchAdMobEvent(named: name, for: params, widget: false)
            return
        }
        /// Step 06. - try to show GADView
        guard display(banner: viewProvider) else { return }

        /// Step 07. Send analytics event if GADView was shown
        dispatchAdMobEvent(named: Constants.Monetization.playerMonLoadingPass, for: params, widget: true)
    }
}
extension APEAdProvider {
    
    static func adMobProvider(
        params                      : AdMobParams,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText            : String,
        inUnitBackgroundColor       : UIColor,
        onAdRequestedCompletion     : @escaping HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping HandlerVoidType,
        receiveAdErrorCompletion    : @escaping HandlerErrorType,
        onAdRemovalCompletion       : @escaping HandlerAdType
    ) -> APEAdProvider {
        
        let provider = APEAdProvider(
            monetization: APEMonetization.adMob(params: params),
            delegate: delegate
        )
        
        provider.nativeDelegate = APEAdMobDelegate.init(
            container: nil,
            receiveAdSuccess: { [provider] in
                provider.statusSuccess()
                provider.bannerView.onReceiveAdSuccess()
                receiveAdSuccessCompletion()
            },
            receiveAdError: { [provider] mistake in
                provider.statusFailure()
                provider.bannerView.onReceiveAdError(mistake)
                receiveAdErrorCompletion(mistake)
            }
        )
        
        let banner = APEAdView(
            adTitleText          : adTitleLabelText,
            monetizationType     : provider.monetization,
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView           : nil,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        // TODO: ARKADI - move this to a diffrent location to make the system load faster
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // let adSizes = params.type.supportedSizes.compactMap {
        //     GADAdSizeFromCGSize($0.size)
        // }
        
        let adSize = params.type == .bottom ? APEAdSize.adSize320x50.size : APEAdSize.adSize300x250.size
        let nativeAdLibView : GADBannerView? = GADBannerView(adSize: GADAdSizeFromCGSize(adSize))
        if let nativeAdView = nativeAdLibView {
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            nativeAdView.adUnitID = params.identifier
            nativeAdView.delegate = provider.nativeDelegate as? GADBannerViewDelegate
        }
        
        banner.adContent       = nativeAdLibView
        provider.bannerView    = banner
        provider.bannerContent = { [weak banner] in banner?.adContent }
        provider.refresh       = { [weak banner] in banner?.adContent?.forceRefreshAd() }
        provider.hide          = { [weak banner] in banner?.hideAd()  }
        provider.show          = { [weak banner] containerDisplay in
            
            guard let adBanner = banner else { return }
            
            if let nativeAdView = nativeAdLibView , !nativeAdView.rootViewController.ape_isExist {
                nativeAdView.rootViewController = delegate.adPresentingViewController
                nativeAdView.load(GADRequest())
                onAdRequestedCompletion()
            }
            if let nativeDelegate = provider.nativeDelegate {
                nativeDelegate.containerViewController = delegate.adPresentingViewController
            }
            adBanner.showAd(in: containerDisplay)
        }
        return provider
    }
}
