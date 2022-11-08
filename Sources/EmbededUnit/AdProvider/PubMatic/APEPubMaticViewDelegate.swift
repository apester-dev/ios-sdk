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
        
        func bannerViewPresentationController() -> UIViewController {
            self.containerViewController ?? UIApplication.shared.windows.first!.rootViewController!
        }

        func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
            receiveAdSuccessCompletion()
        }
        
        func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
            receiveAdErrorCompletion(error)
        }
        
        func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
            
        }
        
        func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
            
        }
        
        func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
            
        }
    }
    
}
