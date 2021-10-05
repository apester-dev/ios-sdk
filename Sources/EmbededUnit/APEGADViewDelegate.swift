//
//  APEGADBannerViewDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 03/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation
import WebKit

// MARK:- GADBannerViewDelegate
@available(iOS 11.0, *)
extension APEUnitView {
    
    struct AdMobProviderParams {
        let adUnitId: String
        let isCompanionVariant: Bool
        
        init?(from dictionary: [String: Any]) {
            guard let provider = dictionary[Constants.Monetization.adProvider] as? String,
                  provider == Constants.Monetization.adMob,
                  let adUnitId = dictionary[Constants.Monetization.adMobUnitId] as? String,
                  let isCompanionVariant = dictionary[Constants.Monetization.isCompanionVariant] as? Bool else {
                return nil
            }
            self.adUnitId = adUnitId
            self.isCompanionVariant = isCompanionVariant
        }
    }
    
    class GADViewDelegate: NSObject, GADBannerViewDelegate {
        let messageDispatcher: MessageDispatcher
        let unitWebView: WKWebView
        let containerViewController: UIViewController?
        
        var isCompanionVariant: Bool = false
        
        init(
            messageDispatcher: MessageDispatcher,
            unitWebView: WKWebView,
            containerViewController: UIViewController?
        ) {
            self.messageDispatcher = messageDispatcher
            self.unitWebView = unitWebView
            self.containerViewController = containerViewController
        }
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            unitWebView.subviews.forEach({ subview in
                unitWebView.bringSubviewToFront(subview)
            })
            unitWebView.layoutIfNeeded()
            messageDispatcher.sendNativeAdEvent(to: unitWebView,
                                                Constants.Monetization.playerMonImpression)
        }
        
        @nonobjc func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
            messageDispatcher.sendNativeAdEvent(to: unitWebView,
                                                Constants.Monetization.playerMonLoadingImpressionFailed)
        }

        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {}

        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {}

        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {}

        func adViewWillLeaveApplication(_ bannerView: GADBannerView) {}
    }
}
