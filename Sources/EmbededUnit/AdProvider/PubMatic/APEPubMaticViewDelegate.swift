//
//  PubMaticViewDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 03/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation
import WebKit

extension APEUnitView {
    
    class PubMaticViewDelegate: NSObject, POBBannerViewDelegate {
        weak var containerViewController: UIViewController?
        private let receiveAdSuccessCompletion: ((PubMaticViewProvider.Params.AdType) -> Void)
        private let receiveAdErrorCompletion: ((PubMaticViewProvider.Params.AdType, Error?) -> Void)
        private let adType: PubMaticViewProvider.Params.AdType
        
        init(adType: PubMaticViewProvider.Params.AdType,
            containerViewController: UIViewController?,
            receiveAdSuccessCompletion: @escaping ((PubMaticViewProvider.Params.AdType) -> Void),
            receiveAdErrorCompletion: @escaping ((PubMaticViewProvider.Params.AdType, Error?) -> Void)
        ) {
            self.adType = adType
            self.containerViewController = containerViewController
            self.receiveAdSuccessCompletion = receiveAdSuccessCompletion
            self.receiveAdErrorCompletion = receiveAdErrorCompletion
        }
        
        func bannerViewPresentationController() -> UIViewController {
            self.containerViewController ?? UIApplication.shared.windows.first!.rootViewController!
        }

        func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
            receiveAdSuccessCompletion(adType)
        }
        
        func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error?) {
            receiveAdErrorCompletion(adType, error)
        }
        
        func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {}
        
        func bannerViewWillPresentModal(_ bannerView: POBBannerView) {}
        
        func bannerViewDidDismissModal(_ bannerView: POBBannerView) {}
    }
    
}
