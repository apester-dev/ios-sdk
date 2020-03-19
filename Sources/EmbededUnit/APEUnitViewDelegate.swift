//
//  APEUnitViewDelegate.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 15/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import WebKit

#if os(iOS)
@available(iOS 11.0, *)

/// This enum describes the link type was activated.
@objc public enum APEUnitViewNavigationType: Int {
    /// Navigation is taking place for some other reason.
    case other
    /// A link with an href attribute was activated by the user.
    case linkActivated
    /// A link for a scoial media was activated by the user.
    case shareLinkActivated
}
/// A ChannelToken Loading state update
@objc public protocol APEUnitViewDelegate: NSObjectProtocol {

    /// when the unitId loaded successfuly
    ///
    /// - Parameters:
    ///   - unitView: the view updater
    ///   - unitId: The mediaId for regular unit or the channel token for playlist
    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId:String)

    /// when the webview couldn't be loaded
    /// - Parameters:
    ///   - unitView: the view updater
    ///   - unitId: The mediaId for regular unit or the channel token for playlist
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId:String)
    
    /// when the unitView height has been updated
    /// - Parameters:
    ///   - unitView: the view updater
    ///   - height: the view new height
    func unitView(_ unitView: APEUnitView, didUpdateHeight height:CGFloat)

    /// when ads completed and not try to get more ads.
    /// - Parameters:
    ///   - unitView: the view updater
    ///   - unitId: The mediaId for regular unit or the channel token for playlist
    func unitView(_ unitView: APEUnitView, adsCompleted token:String)
    
    /// implement this function in order to handle the tapped link URL from the view
    /// - Parameters:
    ///   - unitView: the unit view
    ///   - url: the url to handle
    ///   - completion: the handler callback, return true in case the delegate handles the URL, otherwise return false
    @objc optional
    func unitView(_ unitView: APEUnitView, shouldHandleURL url: URL, type: APEUnitViewNavigationType, completion: @escaping ((Bool) -> Void))
}
#endif
