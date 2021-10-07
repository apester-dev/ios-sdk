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
    
    static var environment: APEEnvironment = .production
    
    static private(set) var unitsParams: [APEUnitParams] = []
    
    static func unitsIds() -> [String] { unitsParams.map(\.id) }
    
    static var gdprString = "COw4XqLOw4XqLAAAAAENAXCAAAAAAAAAAAAAAAAAAAAA.IFukWSQgAIQwgI0QEByFAAAAeIAACAIgSAAQAIAgEQACEABAAAgAQFAEAIAAAGBAAgAAAAQAIFAAMCQAAgAAQiRAEQAAAAANAAIAAggAIYQFAAARmggBC3ZCYzU2yIA.QFukWSQgAIQwgI0QEByFAAAAeIAACAIgSAAQAIAgEQACEABAAAgAQFAEAIAAAGBAAgAAAAQAIFAAMCQAAgAAQiRAEQAAAAANAAIAAggAIYQFAAARmggBC3ZCYzU2yIA.YAAAAAAAAAAAAAAAAAA"
    
    static func configurations(hideApesterAds: Bool, gdprString: String? = nil, baseUrl: String? = nil) -> [APEUnitConfiguration]  {
        
        var unitsParams: [APEUnitParams]!
        
        switch environment {
        case .production:
            unitsParams = [
                .unit(mediaId: "60eeda29b54b6f002448ba79"),
                .playlist(tags: [], channelToken: "56094150b0e393bb4b9f0615", context: false, fallback: false),
                .unit(mediaId: "5e035187675fcbc72ee47156"),
            ]
        case .stage:
            unitsParams = [
                .unit(mediaId: "613d0754e9d41e0024816a38"),
                .unit(mediaId: "5e6fa2351d18fd8580776612"),
                .playlist(tags: ["news", "sport", "yoga"],
                          channelToken: "5dcbc10016698427404a0f57",
                          context: false,
                          fallback: false),
                .playlist(tags: ["yo", "bo", "ho"],
                          channelToken: "5dde8f05694a5dc20a16f3c8",
                          context: false,
                          fallback: false),
            ]
        case .local:
            unitsParams = [.playlist(tags: ["news", "sport", "yoga"],
                                     channelToken: "5d6fc15d07d512002b67ecc6",
                                     context: false,
                                     fallback: false),
                           .unit(mediaId: "5e67bd1c6abc6400725787ab")]
        }
        self.unitsParams = unitsParams
        return makeUnitConfigurations(with: unitsParams, environment: environment, hideApesterAds: hideApesterAds, gdprString: gdprString, baseUrl: baseUrl)
    }
    
    static private func getUnitParam(isPlaylist: Bool, mediaId: String?, channelToken: String?, tags: [String]?, context: Bool?, fallback: Bool?, noApesterAds: Bool) -> [APEUnitParams] {
        return isPlaylist ? [.playlist(tags: tags!, channelToken: channelToken ?? "", context: context ?? false, fallback: fallback ?? false)] : [.unit(mediaId: mediaId!)]
    }
    
    /// transform given media id to APEStripConfiguration
    /// - Parameter unitIds: the unitParams to transform
    static func makeUnitConfigurations(with unitParams: [APEUnitParams], environment: APEEnvironment, hideApesterAds: Bool, gdprString: String?, baseUrl: String?) -> [APEUnitConfiguration] {
        
        unitParams.compactMap {
            APEUnitConfiguration(unitParams: $0, bundle: Bundle.main, hideApesterAds: hideApesterAds, gdprString: gdprString, baseUrl: baseUrl, environment: environment)
        }
        
    }
}
