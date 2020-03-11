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

    static private(set) var mediaId: String = ""

    static func configuration(for env: APEUnitEnvironment = .production) -> APEUnitConfiguration?  {
        var mediaId: String
        
        switch env {
            case .production:
            mediaId = ""
            case .stage:
            mediaId = "5e67832958c4d8457106a2ed"
        case .local:
            mediaId = "5ddeaa945d06ef005f3668e8"
        }
        self.mediaId = mediaId
        return makeUnitConfigurations(with: mediaId, environment: env)
    }
    
    /// transform given media id to APEStripConfiguration
    /// - Parameter mediaId: the mediaId to transform
    static func makeUnitConfigurations(with mediaId: String, environment: APEUnitEnvironment) -> APEUnitConfiguration? {
        
        try? APEUnitConfiguration(mediaId: mediaId,
                                  bundle: Bundle.main, environment: environment)
        
    }
}
