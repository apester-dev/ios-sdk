//
//  APEAdMobViewDelegate.swift
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
    
    class AdMobViewDelegate: NSObject, GADBannerViewDelegate {
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
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            APELoggerService.shared.info("")
            receiveAdSuccessCompletion()
        }
        
        @nonobjc func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
            APELoggerService.shared.info("")
            receiveAdErrorCompletion(error)
        }

        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            APELoggerService.shared.info("")
        }

        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
            APELoggerService.shared.info("")
        }

        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            APELoggerService.shared.info("")
        }

        func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
            APELoggerService.shared.info("")
        }
    }
}
