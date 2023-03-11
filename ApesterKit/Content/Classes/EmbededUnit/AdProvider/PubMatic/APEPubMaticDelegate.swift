//
//  APEPubMaticDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 03/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import UIKit
import Foundation
import OpenWrapSDK

extension POBBannerView : APENativeLibraryAdView
{
    var nativeSize: CGSize { creativeSize().cgSize() }
    func forceRefreshAd() { forceRefresh() }
}

class APEPubMaticDelegate : APENativeLibraryDelegate
{
    
}

// MARK: - POBBannerViewDelegate
extension APEPubMaticDelegate : POBBannerViewDelegate
{
    /// Asks the delegate for a view controller instance to use for presenting modal views as a result of user interaction on an ad. Usual implementation may simply return self, if it is a view controller class.
    func bannerViewPresentationController() -> UIViewController {
        APELoggerService.shared.info()
        return self.containerViewController ?? UIApplication.shared.ape_keyWindow!.rootViewController!
    }
    
    /// Notifies the delegate that an ad has been successfully loaded and rendered.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("||| bannerViewDidReceiveAd: \(bannerView)")
        APELoggerService.shared.info()
        receiveAdSuccess()
    }
    
    /// Notifies the delegate of an error encountered while loading or rendering an ad.
    ///
    /// - Parameters:
    ///   - bannerView: The POBBannerView instance sending the message.
    ///   - error: The error encountered while attempting to receive or render the
    func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
        APELoggerService.shared.info("error: \(error.localizedDescription)")
        receiveAdError(error)
    }
    
    /// Notifies the delegate whenever current app goes in the background due to user click.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        APELoggerService.shared.info()
    }
    
    /// Notifies delegate that the banner view will launch a modal on top of
    /// the current view controller, as a result of user interaction.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
        APELoggerService.shared.info()
    }
    
    /// Notifies delegate that the banner view has dismissed the modal on top of
    /// the current view controller.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
        APELoggerService.shared.info()
    }
    
    /// Notifies the delegate that the banner view was clicked.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewDidClickAd(_ bannerView: POBBannerView) {
        APELoggerService.shared.info()
    }
}
