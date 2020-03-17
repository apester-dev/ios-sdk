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
    
    static private(set) var unitsParams: [APEUnitParams] = []
    
    static func configuration(for env: APEUnitEnvironment = .production, isPlaylist: Bool) -> [APEUnitConfiguration]  {
        
        var unitsParams: [APEUnitParams]!
        
        switch env {
        case .production:
            unitsParams = isPlaylist ? [.playlist(tags: [], channelToken: "", context: false, fallback: false)] : [.unit(mediaId: "")]
        case .stage:
            unitsParams = isPlaylist ? [.playlist(tags: ["news", "sport", "yoga"], channelToken: "5dcbc10016698427404a0f57", context: false, fallback: false)] :  [.unit(mediaId: "5e6fa2351d18fd8580776612")]
        case .local:
            unitsParams =
                isPlaylist ? [.playlist(tags: ["news", "sport", "yoga"], channelToken: "5d6fc15d07d512002b67ecc6", context: false, fallback: false)] :  [.unit(mediaId: "5e67bd1c6abc6400725787ab")]
        }
        self.unitsParams = unitsParams
        return makeUnitConfigurations(with: unitsParams, environment: env)
    }
    
    static private func getUnitParam(isPlaylist: Bool, mediaId: String?, channelToken: String?, tags: [String]?, context: Bool?, fallback: Bool?) -> [APEUnitParams] {
        return isPlaylist ? [.playlist(tags: tags!, channelToken: channelToken ?? "", context: context ?? false, fallback: fallback ?? false)] : [.unit(mediaId: mediaId!)]
    }
        
    /// transform given media id to APEStripConfiguration
    /// - Parameter unitIds: the unitParams to transform
    static func makeUnitConfigurations(with unitParams: [APEUnitParams], environment: APEUnitEnvironment) -> [APEUnitConfiguration] {
        
        unitParams.compactMap {
            APEUnitConfiguration(unitParams: $0, bundle: Bundle.main, environment: environment)
        }
        
    }
}
