//
//  PubMaticAnnotationDelegate.swift
//  ApesterKit
//
// This class is stand for holding the POBBannerViewDelegate
// It's better if APEUnitView will be able to include this delegate but
// it's casue an error with GADBannerViewDelegate:
//
// `Method 'bannerViewDidReceiveAd' with Objective-C selector 'bannerViewDidReceiveAd:' conflicts with previous declaration with the same Objective-C selector`
//
//  Created by Almog Haimovitch on 04/05/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation

public class PubMaticDelegate: NSObject, POBBannerViewDelegate {
    
    weak var apeUnitView: APEUnitView!
    
    init(apeUnitView: APEUnitView) {
        self.apeUnitView = apeUnitView
    }
    public func bannerViewPresentationController() -> UIViewController {
        if let containerViewController = self.apeUnitView.containerViewConroller {
            return containerViewController
        } else {
            return UIApplication.shared.windows.first!.rootViewController!
        }
    }
    
        // Notifies the delegate that an ad has been successfully loaded and rendered.
        public func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
            self.apeUnitView.messageDispatcher.sendNativeAdEvent(to: self.apeUnitView.unitWebView, Constants.Monetization.playerMonImpression)
        }
    
    // Notifies the delegate an error occurred while loading or rendering an ad.
    public func bannerView(_ bannerView: POBBannerView,
                               didFailToReceiveAdWithError error: Error?) {
        self.apeUnitView.messageDispatcher.sendNativeAdEvent(to: self.apeUnitView.unitWebView, Constants.Monetization.playerMonLoadingImpressionFailed)
    }
         
    // Notifies the delegate whenever current app goes in the background due to user click
    public func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        
    }
         
    // Notifies the delegate that the banner ad will launch a modal on top of the current view controller,
    // as a result of user interaction
    public func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
    }
     
    // Notifies the delegate that the banner ad view has closed the modal.
    public func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
    }
    
}
