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
            APELoggerService.shared.info()
            return self.containerViewController ?? UIApplication.shared.windows.first!.rootViewController!
        }

        func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
            APELoggerService.shared.info()
            receiveAdSuccessCompletion()
        }
        
        func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
            APELoggerService.shared.info()
            receiveAdErrorCompletion(error)
        }
        
        func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
            APELoggerService.shared.info()
        }
        
        func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
            APELoggerService.shared.info()
        }
        
        func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
            APELoggerService.shared.info()
        }
    }
    
}
