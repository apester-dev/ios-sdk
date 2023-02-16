//
//  APEAdMobViewDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 03/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation
import WebKit
import GoogleMobileAds

// MARK:- GADBannerViewDelegate
@available(iOS 11.0, *)
extension APEUnitView {
    
    class AdMobViewDelegate : NSObject , GADBannerViewDelegate {
        
        weak var containerViewController: UIViewController?
        
        private let receiveAdSuccessCompletion: (() -> Void)
        private let receiveAdErrorCompletion: ((Error?) -> Void)
        
        init(
            containerViewController: UIViewController?,
            receiveAdSuccessCompletion: @escaping (() -> Void),
            receiveAdErrorCompletion: @escaping ((Error?) -> Void)
        ) {
            self.containerViewController = containerViewController
            self.receiveAdSuccessCompletion = receiveAdSuccessCompletion
            self.receiveAdErrorCompletion = receiveAdErrorCompletion
        }
        
        // MARK: - Ad Request Lifecycle Notifications
        /// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
        /// the banner view to the view hierarchy if it hasn't been added yet.
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            APELoggerService.shared.info()
            receiveAdSuccessCompletion()
        }
        
        /// Tells the delegate that an ad request failed. The failure is normally due to network
        /// connectivity or ad availablility (for example, no fill).
        @nonobjc func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
            APELoggerService.shared.info()
            receiveAdErrorCompletion(error)
        }
        
        /// Tells the delegate that an impression has been recorded for an ad.
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            APELoggerService.shared.info()
        }
        /// Tells the delegate that a click has been recorded for the ad.
        func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
            APELoggerService.shared.info()
        }
        
        // MARK: - Click-Time Lifecycle Notifications
        
        /// Tells the delegate that a full screen view will be presented in response to the user clicking on
        /// an ad. The delegate may want to pause animations and time sensitive interactions.
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            APELoggerService.shared.info()
        }
        
        /// Tells the delegate that the full screen view will be dismissed.
        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
            APELoggerService.shared.info()
        }
        
        /// Tells the delegate that the full screen view has been dismissed. The delegate should restart
        /// anything paused while handling bannerViewWillPresentScreen:.
        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            APELoggerService.shared.info()
        }
    }
}
