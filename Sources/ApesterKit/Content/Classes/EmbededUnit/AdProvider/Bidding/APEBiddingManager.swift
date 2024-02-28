//
//  APEBiddingManager.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 4/3/23.
//

import Foundation

// TODO: - finish this description
/// Protocol to get the notification after the responses are received from all the bidders.
@objc(APEBiddingManagerDelegate)
internal protocol APEBiddingManagerDelegate : NSObjectProtocol
{
    /// Method to notify manager class on receiving ad response successfully.
    /// - Parameter response: Response/Targeting information
    @objc func didReceiveResponse(_ response: [String: Any]?)
    
    /// Method to notify manager class if error occured.
    /// - Parameter error: Error object
    @objc func didFail(toReceiveResponse error: Error?)
}


///  Bidding manager class to manage bids loaded from all the bidders
///  of various SDKs, e.g. TAM
///
///  This class internally waits for all the bidders to respond with success/failure and notifies the
///  calling class with aggregated response once all responses are received.

final internal class APEBiddingManager : NSObject
{
    /// a delegate for BiddingManagerDelegate protocol to notify once response from all the bidders is received.
    internal weak var delegate: APEBiddingManagerDelegate?
    
    // Array of registered bidders.
    private var biddersList: [APEBidding]
    
    /// Queue of registered bidders.
    /// It will have same objects as biddersList but, the bidders will be removed from biddersQueue once they respond. ( be it success or failure)
    ///
    /// The objects from biddersList will not be modified.
    private var biddersQueue: [APEBidding]
    
    /// Combined list of all responses from all the bidders, stored in the form of dictionary
    /// eg. {bidderName1: response1, bidderName2: response2, ...}
    /// response1, response2 etc. are key-value pairs of targeting information.
    private var responses : [String: Any]
    
    /// Flag to identify if response from OpenWrap SDK is received.
    private var adsLibraryResponseReceived : Bool
    
    internal override init()
    {
        self.adsLibraryResponseReceived = false
        self.biddersList  = [APEBidding]()
        self.biddersQueue = [APEBidding]()
        self.responses    = [String: Any]()
        super.init()
    }
    
    /// Method to register bidders in bidding manager.
    ///     Separate class should be created for each ad server integration
    ///     implementing Bidding protocol and should be registered in bidding manager.
    ///
    ///     Bidding manager keeps the bidders in a queue, sends load bids request simultaniously
    ///     to all the registered bidders
    /// - Parameter bidder: Bidder object implementing Bidding protocol
    internal func register(Bidder bidder: APEBidding)
    {
        // Add bidder in bidder's list.
        // Please note, bidders should be registered only once.
        guard !biddersList.contains(where: { $0.isEqual(bidder) }) else { return }
        
        // Set bidder object delegate to report to the manager.
        bidder.delegate = self
        biddersList.append(bidder)
    }
    
    /// Use to trigger bidding manager to load bids.
    /// Bidding manager internally instructs all the registered bidders to load bids using Bidding protocol.
    internal func loadBids()
    {
        biddersQueue.removeAll()
        responses.removeAll()
        
        biddersQueue.append(contentsOf: biddersList)
        biddersQueue.forEach { $0.loadBids() }
    }
    
    /// Notifies the bidding manager about ads Library response (success/failure)
    internal func notifyAdsLibraryBidEvent() {
        adsLibraryResponseReceived = true

        // Call processResponse as OpenWrap's bids are received.
        processResponse()
    }
    
    internal func retrivePartnerTargeting() -> [String: Any]
    {
        let partnerData = responses
        responses.removeAll()
        return partnerData
    }
}
// MARK: - Private methods
private extension APEBiddingManager
{
    
    /// Method to remove bidder from biddersQueue once it responds with success/failure.
    /// - Parameter bidder: bidder to remove
    func removeRespondedBidder(_ bidder: APEBidding) {
        
        biddersQueue.removeAll { $0.isEqual(bidder) }
    }
    
    /**
     Method to process received responses.
     This internally checks if all the bidders have responded. If yes, it notifies
     view controller about aggregated responses using BiddingManagerDelegate protocol.
     So, it is required to call this method everytime, response is
     received from any bidder.
     */
    func processResponse() {

        // Wait for all the bidders and Ad Library to respond
        guard biddersQueue.isEmpty       else { return }
        guard adsLibraryResponseReceived else { return }
        defer {
            biddersQueue.removeAll()
            adsLibraryResponseReceived = false
        }
        
        if responses.keys.count > 0 {
            delegate?.didReceiveResponse(responses)
        } else {
            let error = NSError(
                domain: "Failed to receive targeting from all the bidders.",
                code: -1,
                userInfo: nil
            )
            delegate?.didFail(toReceiveResponse: error)
        }
    }
}
extension APEBiddingManager : APEBidderDelegate
{
    func bidder(_ bidder: APEBidding, didReceivedAdResponse response: [String : Any])
    {
        // The bidder responded with success, collect all the responses
        // in responses map and remove it from bidders queue.
        responses = responses.merging(response) { (_, new) in new }
        removeRespondedBidder(bidder)
        processResponse()
    }
    
    func bidder(_ bidder: APEBidding, didFailToReceiveAdWithError error: Error?)
    {
        // The bidder have responded with failure, so remove it from bidders queue
        removeRespondedBidder(bidder)
        processResponse()
    }
}
