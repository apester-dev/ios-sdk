//
//  APEAmazonDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 03/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//
import UIKit
import Foundation
///
///
///
import OpenWrapSDK
import OpenWrapHandlerDFP
///
///
///
class APEAmazonDelegate : APENativeLibraryDelegate
{
    private var isActiveAd = false

    // MARK: - APEBiddingManagerDelegate
    override func didReceiveResponse(_ response: [String : Any]?)
    {
        guard let provider = adProvider else { return }
        provider.bannerContent()?.proceedToTriggerLoadAd()
    }
    
    override func didFail(toReceiveResponse error: Error?)
    {
        guard let provider = adProvider else { return }
        provider.bannerContent()?.proceedToTriggerLoadAd()
    }
}
// MARK: - POBBannerViewDelegate
extension APEAmazonDelegate : POBBannerViewDelegate
{
    /// Asks the delegate for a view controller instance to use for presenting modal views as a result of user interaction on an ad. Usual implementation may simply return self, if it is a view controller class.
    func bannerViewPresentationController() -> UIViewController
    {
        APELoggerService.shared.info()
        return self.containerViewController ?? UIApplication.shared.ape_keyWindow!.rootViewController!
    }
    
    /// Notifies the delegate that an ad has been successfully loaded and rendered.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView)
    {
        print("||| bannerViewDidReceiveAd: \(bannerView)")
        APELoggerService.shared.info()
        receiveAdSuccess()
        
        // OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
        // To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        biddingManager.loadBids()
    }
    
    /// Notifies the delegate of an error encountered while loading or rendering an ad.
    ///
    /// - Parameters:
    ///   - bannerView: The POBBannerView instance sending the message.
    ///   - error: The error encountered while attempting to receive or render the
    func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error)
    {
        APELoggerService.shared.info("error: \(error.localizedDescription)")
        receiveAdError(error)
        
        // OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
        // To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        biddingManager.loadBids()
    }
    
    /// Notifies the delegate whenever current app goes in the background due to user click.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView)
    {
        APELoggerService.shared.info()
    }
    
    /// Notifies delegate that the banner view will launch a modal on top of
    /// the current view controller, as a result of user interaction.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView)
    {
        APELoggerService.shared.info()
    }
    
    /// Notifies delegate that the banner view has dismissed the modal on top of
    /// the current view controller.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView)
    {
        APELoggerService.shared.info()
    }
    
    /// Notifies the delegate that the banner view was clicked.
    ///
    /// - Parameter bannerView: The POBBannerView instance sending the message.
    func bannerViewDidClickAd(_ bannerView: POBBannerView)
    {
        APELoggerService.shared.info()
    }
}
// MARK: - POBBidEventDelegate
extension APEAmazonDelegate : POBBidEventDelegate
{
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!)
    {
        APELoggerService.shared.info()
        
        // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
        // Notify bidding manager that OpenWrap's success response is received.
        if !isActiveAd {
            bidEventObject.proceedToLoadAd()
            biddingManager.notifyAdsLibraryBidEvent()
        }
    }
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!)
    {
        APELoggerService.shared.info()
        
        // Notify bidding manager that OpenWrap's failure response is received.
        biddingManager.notifyAdsLibraryBidEvent()
    }
}

// MARK: POBInterstitialDelegate
extension APEAmazonDelegate: POBInterstitialDelegate {
    func interstitialDidReceiveAd(_ interstitial: POBInterstitial) {
        print("||| intersittial ad received: \(interstitial)")
        APELoggerService.shared.info()
        receiveAdSuccess()
        if let adLoadedCall = adLoaded {
            adLoadedCall()
        }
        // OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
        // To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        biddingManager.loadBids()
    }
    
    func interstitial(_ interstitial: POBInterstitial, didFailToReceiveAdWithError error: NSError) {
        print("Failed to receive ad: \(error.localizedDescription)")
    }
    
    func interstitialDidDismissAd(_ interstitial: POBInterstitial) {
        
        print("Ad dismissed")
    }
    func interstitialWillPresentAd(_ interstitial: POBInterstitial) {
        print("interstitial will present ad")
        isActiveAd = true
    }
    func interstitial(_ interstitial: POBInterstitial, didFailToShowAdWithError error: Error) {
        print("failed to show ad error: \(error)")
    }
    
}

