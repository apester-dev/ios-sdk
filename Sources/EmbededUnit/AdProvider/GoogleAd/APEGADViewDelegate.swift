//
//  APEGADViewDelegate.swift
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
    
    class GADViewDelegate: NSObject, GADBannerViewDelegate {
        let containerViewController: UIViewController?
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
            receiveAdSuccessCompletion()
        }
        
        @nonobjc func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
            receiveAdErrorCompletion(error)
        }

        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {}

        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {}

        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {}

        func adViewWillLeaveApplication(_ bannerView: GADBannerView) {}
    }
}
