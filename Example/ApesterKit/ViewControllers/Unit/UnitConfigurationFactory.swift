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
    static var gdprString = "CPlrcMAPlrcMACnABIDECzCkAP_AAAAAAAYgI8pd9D7dbXFDefx_SPt0OYwW0NBTKuQCChSAA2AFVAOQcLQA02EaMATAhiACEQIAolIBAAEEHAFUAECQQIAEAAHsIgSEhAAKIABEEBEQAAIQAAoKAAAAEAAIgAABIgSAmBiQS5LmRUCAGIAQBgBYgogBCIABAgMBBEAIABgIAIIIwygAAQAAAIIAAAAAARAAAgAAAJCQAYAAgjyGgAwABBHkRABgACCPIqADAAEEeRkAGAAII8joAMAAQR5IQAYAAgjySgAwABBHkpABgACCPIAA.f_gAAAAABcgAAAAA"
//
    static var baseUrl = "https://www.kicker.de/apester-in-app-unit-detached"

    static private(set) var unitsParams: [(type: UnitType, unitParam:APEUnitParams)] = []
    
    static func unitsIds() -> [String] { unitsParams.map(\.unitParam.id) }
        
    static func configurations(hideApesterAds: Bool, gdprString: String? = nil, baseUrl: String? = nil) -> [APEUnitConfiguration]  {
        
        var unitsParams: [(type: UnitType, unitParam:APEUnitParams)]!
        switch environment {
        case .production:
            unitsParams = [
                (.Quiz,.unit(mediaId: "65941b08a7dea3751aad1574")),
                (.Story,.unit(mediaId: "6593f8b05a52477af6253ba9")),
                (.Poll,.unit(mediaId: "65bb5a8567da18d2012eed05")),
                (.Quiz,.unit(mediaId: "6592bc1c3e05b25017d45081")),
                (.Story,.unit(mediaId: "6592baff8d2f93812c57566c")),
                (.Poll,.unit(mediaId: "6592bb800115251940120dc0")),
                (.Quiz,.unit(mediaId: "6592bf983021cfab8b0b5d61")),
                (.Story,.unit(mediaId: "6592be633021cfab8b0ac676")),
                (.Poll,.unit(mediaId: "5f045f3db203aadd7a2e8e08"))
           
                // .unit(mediaId: "61ee7ff6a5e14a002b6c044a"), //.unit(mediaId: "60eeda29b54b6f002448ba79"),
//                (.Playlist,.playlist(tags: [], channelToken: "6411d62f2044dc001228e095", context: false, fallback: false)),
//                .playlist(tags: [], channelToken: "61ee7fd7a33874001368f396", context: false, fallback: false)
            ]
        case .stage:
            unitsParams = [
                (.Poll,.unit(mediaId: "656db02508e812a5025b732d")),
                (.Quiz,.unit(mediaId: "5e6fa2351d18fd8580776612")),
                (.Playlist,.playlist(tags: ["news", "sport", "yoga"],
                          channelToken: "5dcbc10016698427404a0f57",
                          context: false,
                          fallback: false)),
                (.Playlist,.playlist(tags: ["yo", "bo", "ho"],
                          channelToken: "5dde8f05694a5dc20a16f3c8",
                          context: false,
                          fallback: false)),
            ]
//        case .local:
//            unitsParams = [
//                ( .Poll,.unit(mediaId: "5e67bd1c6abc6400725787ab")),
//                (.Playlist,.playlist(tags: ["news", "sport", "yoga"],
//                          channelToken: "5d6fc15d07d512002b67ecc6",
//                          context: false,
//                          fallback: false)),
//            ]
        case .dev:
            unitsParams = [
                (.Poll,.unit(mediaId: "656db02508e812a5025b732d")),
            ]
        }
        self.unitsParams = unitsParams
        return makeUnitConfigurations(with: unitsParams, environment: environment, hideApesterAds: hideApesterAds, gdprString: gdprString, baseUrl: self.baseUrl)
    }
    
    static private func getUnitParam(isPlaylist: Bool, mediaId: String?, channelToken: String?, tags: [String]?, context: Bool?, fallback: Bool?, noApesterAds: Bool) -> [APEUnitParams] {
        return isPlaylist ? [.playlist(tags: tags!, channelToken: channelToken ?? "", context: context ?? false, fallback: fallback ?? false)] : [.unit(mediaId: mediaId!)]
    }
    
    /// transform given media id to APEStripConfiguration
    /// - Parameter unitIds: the unitParams to transform
    static func makeUnitConfigurations(with unitParams: [(type: UnitType, unitParam:APEUnitParams)], environment: APEEnvironment, hideApesterAds: Bool, gdprString: String?, baseUrl: String?) -> [APEUnitConfiguration] {
        
        unitParams.compactMap {
            let config = APEUnitConfiguration(unitParams: $0.unitParam, bundle: Bundle.main, hideApesterAds: hideApesterAds, gdprString: gdprString, baseUrl: baseUrl, environment: environment)
                config.setFullscreen(true)
            return config
        }
        
    }
}
