//
//  APEStripViewDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 11/18/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import WebKit

#if os(iOS)
@available(iOS 11.0, *)

/// This enum describes the link type was activated.
@objc public enum APEStripViewNavigationType: Int {
    /// Navigation is taking place for some other reason.
    case other
    /// A link with an href attribute was activated by the user.
    case linkActivated
    /// A link for a scoial media was activated by the user.
    case shareLinkActivated
}
/// A ChannelToken Loading state update
@objc public protocol APEStripViewDelegate: NSObjectProtocol {

    /// when the ChannelToken loaded successfuly
    ///
    /// - Parameters:
    ///   - stripView: the strip view updater
    ///   - token: the channel token id
    func stripView(_ stripView: APEStripView, didFinishLoadingChannelToken token:String)

    /// when the ChannelToken couldn't be loaded
    /// - Parameters:
    ///   - stripView: the strip view updater
    ///   - token: the channel token id
    func stripView(_ stripView: APEStripView, didFailLoadingChannelToken token:String)

    /// when the stripView height has been updated
    /// - Parameters:
    ///   - stripView: the strip view updater
    ///   - height: the stripView new height
    func stripView(_ stripView: APEStripView, didUpdateHeight height:CGFloat)

    /// when a subscribed event message has been recived
    /// for Example, subscribe to load and ready events by: `stripView.subscribe(["strip_loaded", "apester_strip_units"])`
    /// - Parameters:
    ///   - stripView: the strip view
    ///   - name: the subscribed event
    ///   - message: the message data for that event
    @objc optional
    func stripView(_ stripView: APEStripView, didReciveEvent name:String, message: String)


    /// implement this function in order to handle the tapped link URL from the strip view
    /// - Parameters:
    ///   - stripView: the strip view
    ///   - url: the url to handle
    ///   - completion: the handler callback, return true in case the delegate handles the URL, otherwise return false
    @objc optional
    func stripView(_ stripView: APEStripView, shouldHandleURL url: URL, type: APEStripViewNavigationType, completion: @escaping ((Bool) -> Void))
}
#endif
