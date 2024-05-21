//
//  APEAmazonStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
///
///
///
import DTBiOSSDK
/// Bidder class to load bids from TAM SDK.
final internal class APEAmazonAdLoader : NSObject
{
    /// Sets the BidderDelegate delegate receiver which will notify about response
    ///  (success/failure) from TAM SDK to bidding manager
    internal weak var delegate: APEBidderDelegate?
    
    var adSizes  : [DTBAdSize]?
    var adLoader : DTBAdLoader?
    
    init(SlotUUID identifier: String, apesterSize : APEAdSize)
    {
        self.adSizes = [
            DTBAdSize(
                bannerAdSizeWithWidth: Int(apesterSize.size.width),
                height: Int(apesterSize.size.height),
                andSlotUUID: identifier
            )
        ]
        super.init()
    }
    override init() {
        super.init()
    }
}
extension APEAmazonAdLoader : APEBidding
{
    internal func loadBids()
    {
        APELoggerService.shared.debug("TAM: Loading ad from A9 TAM SDK")
        let loader = DTBAdLoader()
        if let sizes = adSizes {
            loader.setAdSizes(sizes)
        }

        loader.loadAd(self)
        adLoader = loader
    }
}
extension APEAmazonAdLoader : DTBAdCallback
{
    func onSuccess(_ adResponse: DTBAdResponse!) {
        APELoggerService.shared.debug("TAM: Received Response From A9 TAM SDK")
        
        // Pass TAM custom targeting parameters to bidding manager.
        guard let custom = adResponse?.customTargeting() else { return }
        delegate?.bidder( self, didReceivedAdResponse: [ "TAM": custom ])
    }
    
    func onFailure(_ error: DTBAdError) {
        APELoggerService.shared.debug("TAM: Failed to load ad with error :\(error)")
        
        let err = NSError(
            domain: "Failed to load ad from TAM SDK.", code: Int(error.rawValue), userInfo: nil)
        // Notify failure to bidding manager
        delegate?.bidder(self, didFailToReceiveAdWithError: err)
    }
}
