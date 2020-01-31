//
//  APEStripViewService.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 1/31/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import UIKit

@objcMembers public class APEStripViewService: NSObject {

    public static let shared = APEStripViewService()

    private var stripViewsData: [String: APEStripView] = [:]

    private override init() {}

    /// Preload multiple strip views with strip configurations,
    /// each configuration will contains all the data to cache the strip view to get loaded,
    /// i.e the channel token, style etc...
    /// - Parameter configurations: the configurations to preload
    public func preloadStripViews(with configurations: [APEStripConfiguration]) {
        DispatchQueue.main.async {
            let configs = configurations.filter({ self.stripView(for: $0.channelToken) == nil })
            let stripViewsData = configs.reduce(into: [:]) {
                $0[$1.channelToken] = APEStripView(configuration: $1)
            }
            self.stripViewsData.merge(stripViewsData, uniquingKeysWith: { $1 })
        }
    }

    /// Unload strip views so it can be Removed from cache with the given channelTokens if exists
    /// - Parameter channelTokens: the channelTokes to remove from cache
    public func unloadStripViews(with channelTokens: [String]) {
        DispatchQueue.main.async {
            channelTokens.forEach {
                self.stripViewsData[$0] = nil
            }
        }
    }

    /// Get Cached strip view for the given channelToken if exists..
    /// FYI, the stripView value will be nil in case it hasn't been initialized Via the `preloadStripViews` API first.
    /// - Parameter channelToken: the channelToken
    public func stripView(for channelToken: String) -> APEStripView? {
        self.stripViewsData[channelToken]
    }
}
