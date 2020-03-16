//
//  UnitConfigurationFactory.swift
//  Apester
//
//  Created by Almog Haimovitch on 11/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit
import ApesterKit

@objcMembers class UnitConfigurationsFactory: NSObject {
    
    static private(set) var mediaIds: [String] = [""]
    
    static func configuration(for env: APEUnitEnvironment = .production) -> [APEUnitConfiguration]  {
        var mediaIds: [String]
        
        switch env {
        case .production:
            mediaIds = [""]
        case .stage:
            mediaIds = ["5e67832958c4d8457106a2ed"]
        case .local:
            mediaIds = ["5d7f7f5f8ff01b0072a496da"]
        }
        self.mediaIds = mediaIds
        return makeUnitConfigurations(with: mediaIds, environment: env)
    }
    
    /// transform given media id to APEStripConfiguration
    /// - Parameter mediaId: the mediaId to transform
    static func makeUnitConfigurations(with mediaIds: [String], environment: APEUnitEnvironment) -> [APEUnitConfiguration] {
        
        mediaIds.compactMap {
            try? APEUnitConfiguration(mediaId: $0, bundle: Bundle.main, environment: environment)
        }
        
    }
}
