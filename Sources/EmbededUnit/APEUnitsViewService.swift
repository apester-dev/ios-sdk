//
//  APEUnitViewService.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 11/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import UIKit

@objcMembers public class APEUnitsViewService: NSObject {

    public static let shared = APEUnitsViewService()
    private var unitViewsData: [String: APEUnitView] = [:]

    private override init() {}

    /// Preload view with unit configuration,
    /// configuration will contains the data to cache the view that has loaded,
    /// - Parameter configuration: the configuration to preload
    public func preloadUnitsView(with configurations: [APEUnitConfiguration]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.preloadUnitsView(with: configurations) }
            return
        }
        
        let configs = configurations.filter({ self.unitView(for: $0.unitParams) == nil })
        let unitViewsData = configs.reduce(into: [:]) {
            $0[$1.unitParams.id] = APEUnitView(configuration: $1)
        }
        self.unitViewsData.merge(unitViewsData, uniquingKeysWith: { $1 })
        
    }
    
    /// Unload units views so it can be Removed from cache with the given mediaIds if exists
    /// - Parameter mediaIds: the mediaIds to remove from cache
    public func unloadUnitsViews(with mediaIds: [String]) {
        DispatchQueue.main.async {
            mediaIds.forEach {
                self.unitViewsData[$0] = nil
            }
        }
    }

    /// Get Cached unit view for the given mediaId if exists..
    /// FYI, the unit value will be nil in case it hasn't been initialized Via the `preloadUnitViews` API first.
    /// - Parameter unitParams: the APEUnitParams
    public func unitView(for unitParams: APEUnitParams) -> APEUnitView? {
        return self.unitViewsData[unitParams.id]
    }

}
