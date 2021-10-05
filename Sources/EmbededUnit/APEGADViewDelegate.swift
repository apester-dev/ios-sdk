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
    
    struct GADViewProvider {
        var view: GADBannerView?
        var delegate: GADViewDelegate?
    }
    
    struct GADViewProviderParams: Hashable {
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
