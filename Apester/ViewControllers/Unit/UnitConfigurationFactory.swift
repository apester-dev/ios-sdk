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
    
    static func configurations(for env: APEEnvironment = .production, hideApesterAds: Bool, gdprString: String?) -> [APEUnitConfiguration]  {
        
        var unitsParams: [APEUnitParams]!
        
        switch env {
            case .production:
                unitsParams = [
                    .playlist(tags: [], channelToken: "56094150b0e393bb4b9f0615", context: false, fallback: false),
                               .unit(mediaId: "5e035187675fcbc72ee47156"),
                               .unit(mediaId: "5e03516573255b340854cbf8")]
            case .stage:
                unitsParams = [
                               .unit(mediaId: "5defe53f4151fc87675e3ec5"),
                               .playlist(tags: ["news", "sport", "yoga"],
                                         channelToken: "5dcbc10016698427404a0f57",
                                         context: false,
                                         fallback: false),
                               .playlist(tags: ["yo", "bo", "ho"],
                                         channelToken: "5dde8f05694a5dc20a16f3c8",
                                         context: false,
                                         fallback: false),
                               .unit(mediaId: "5e6fa2351d18fd8580776612"),
            ]
        case .local:
            unitsParams = [.playlist(tags: ["news", "sport", "yoga"],
                                     channelToken: "5d6fc15d07d512002b67ecc6",
                                     context: false,
                                     fallback: false),
                           .unit(mediaId: "5e67bd1c6abc6400725787ab")]
        }
        self.unitsParams = unitsParams
        return makeUnitConfigurations(with: unitsParams, environment: env, hideApesterAds: hideApesterAds, gdprString: gdprString)
    }
    
    static private func getUnitParam(isPlaylist: Bool, mediaId: String?, channelToken: String?, tags: [String]?, context: Bool?, fallback: Bool?, noApesterAds: Bool) -> [APEUnitParams] {
        return isPlaylist ? [.playlist(tags: tags!, channelToken: channelToken ?? "", context: context ?? false, fallback: fallback ?? false)] : [.unit(mediaId: mediaId!)]
    }
        
    /// transform given media id to APEStripConfiguration
    /// - Parameter unitIds: the unitParams to transform
    static func makeUnitConfigurations(with unitParams: [APEUnitParams], environment: APEEnvironment, hideApesterAds: Bool, gdprString: String?) -> [APEUnitConfiguration] {
        
        unitParams.compactMap {
            APEUnitConfiguration(unitParams: $0, bundle: Bundle.main, hideApesterAds: hideApesterAds, gdprString: gdprString, environment: environment)
        }
        
    }
}
