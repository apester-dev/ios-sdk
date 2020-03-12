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
    public private(set) var unitView: APEUnitView?

    private override init() {}

    /// Preload view with unit configuration,
    /// configuration will contains the data to cache the view that has loaded,
    /// - Parameter configuration: the configuration to preload
    public func preloadUnitView(with configuration: APEUnitConfiguration) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.preloadUnitView(with: configuration) }
            return
        }
        
        self.unitView = APEUnitView(configuration: configuration)
        
    }

}
