//
//  APEUnitViewService.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 11/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import UIKit

@objcMembers public class APEUnitViewService: NSObject {

    public static let shared = APEUnitViewService()

    private var unitViewData: APEUnitView?

    private override init() {}

    /// Preload view with unit configuration,
    /// configuration will contains the data to cache the view that has loaded,
    /// - Parameter configuration: the configuration to preload
    public func preloadUnitView(with configuration: APEUnitConfiguration) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.preloadUnitView(with: configuration) }
            return
        }
        
        let apeUnitWebView = APEUnitView(configuration: configuration)

        self.unitViewData = apeUnitWebView
        
    }

    /// Unload view so it can be Removed from cache with the given mediaId if exists
    /// - Parameter mediaId: the mediaId to remove from cache
//    public func unloadUnitView() {
//        DispatchQueue.main.async {
//            self.unitViewData = nil
//        }
//    }

    /// Get Cached view if exists..
    /// FYI, the view value will be nil in case it hasn't been initialized Via the `preloadUnitView` API first.
    /// - Parameter mediaId: the mediaId
    public func unitView() -> APEUnitView? {
        self.unitViewData
    }
}
