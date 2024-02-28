//
//  APENativeLibrary.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//
import Foundation

/// Protocol to be implemented by all the classes that are fetching bids
/// from ad servers.
///
/// Separate class should be created for each ad server integrations (e.g. TAM)
/// and that class should implement this protocol in order to manage all the bids at one place
/// i.e. a bidding manager.
internal protocol APEBidding : NSObjectProtocol
{
    /// This property of BidderDelegate can be used to notify below events to bidding manager
    /// e.g bids received, bids failed.
    var delegate : APEBidderDelegate? { get set }

    /// Method to instruct bidder class to load the bid.
    func loadBids()
}

/// A protocol, which is used to provide response from different partners to centralised bidding manager
internal protocol APEBidderDelegate : AnyObject
{
    /// Method to notify manager class on receiving bids successfully by bidder.
    /// - Parameters:
    ///   - bidder: Object of a bidder sending notification
    ///   - response: Targeting information in a dictionary representation. I.E - @{ bidderName : Response }
    func bidder(_ bidder: APEBidding, didReceivedAdResponse response: [String:Any])
    
    /// Method to notify manager class on receiving failure while fetching bids by bidder.
    /// - Parameters:
    ///   - bidder: Object of a bidder sending notification
    ///   - error: Error object
    func bidder(_ bidder: APEBidding, didFailToReceiveAdWithError error: Error?)
}

