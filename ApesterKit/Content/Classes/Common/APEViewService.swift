//
//  APEViewService.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 3/19/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import UIKit


/// APEView caching service
@objc(APEViewService)
@objcMembers
public class APEViewService: NSObject {

    public static let shared = APEViewService()

    private var stripControllers: [String: APEStripView] = [:]
    private var  unitControllers: [String: APEUnitView ] = [:]

    private override init() {}
}

// MARK:- Preload APEStripViews
@objc
public extension APEViewService {

    /// Preload multiple strip views with strip configurations,
    /// each configuration will contains all the data to cache the strip view to get loaded,
    /// i.e the channel token, style etc...
    /// - Parameter configurations: the configurations to preload
    func preloadStripViews(with configurations: [APEStripConfiguration]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.preloadStripViews(with: configurations) }
            return
        }
        let configs = configurations.filter({ self.stripView(for: $0.channelToken) == nil })
        let stripViewsData = configs.reduce(into: [:]) {
            $0[$1.channelToken] = APEStripView(configuration: $1)
        }
        self.stripControllers.merge(stripViewsData, uniquingKeysWith: { $1 })
    }

    /// Unload strip views so it can be Removed from cache with the given channelTokens if exists
    /// - Parameter channelTokens: the channelTokes to remove from cache
    func unloadStripViews(with channelTokens: [String]) {
        DispatchQueue.main.async {
            channelTokens.forEach {
                self.stripControllers[$0] = nil
            }
        }
    }

    /// Get Cached strip view for the given channelToken if exists..
    /// FYI, the stripView value will be nil in case it hasn't been initialized Via the `preloadStripViews` API first.
    /// - Parameter channelToken: the channelToken
    func stripView(for channelToken: String) -> APEStripView? {
        self.stripControllers[channelToken]
    }

}

// MARK:- Preload APEUnitViews
@objc
public extension APEViewService {
    /// Preload view with unit configuration,
    /// configuration will contains the data to cache the view that has loaded,
    /// - Parameter configurations: the configuration to preload
    func preloadUnitViews(with configurations: [APEUnitConfiguration]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.preloadUnitViews(with: configurations) }
            return
        }

        let configs = configurations.filter({ self.unitView(for: $0.unitParams.id) == nil })
        let unitViewsData = configs.reduce(into: [:]) {
            $0[$1.unitParams.id] = APEUnitView(configuration: $1)
        }
        self.unitControllers.merge(unitViewsData, uniquingKeysWith: { $1 })

    }

    /// Unload units views so it can be Removed from cache with the given unitIds if exists
    /// - Parameter unitIds: the mediaIds to remove from cache
    func unloadUnitViews(with unitIds: [String]) {
        DispatchQueue.main.async {
            unitIds.forEach {
                self.unitControllers[$0] = nil
            }
        }
    }

    /// Get Cached unit view for the given unitId if exists..
    /// FYI, the unit value will be nil in case it hasn't been initialized Via the `preloadUnitViews` API first.
    /// - Parameter id: the APEUnitParams
    func unitView(for id: String) -> APEUnitView? {
        return self.unitControllers[id]
    }
}
