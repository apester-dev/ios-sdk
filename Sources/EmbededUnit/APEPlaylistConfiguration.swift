//
//  APEPlaylistConfiguration.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 16/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import UIKit
                          
@objcMembers public class APEPlaylistConfiguration: APEConfiguration {

    private enum Keys: String {
        case channelToken = "channelToken"
    }
    
    public var channelToken: String
    public var tags: [String]

//    private var parameters: [String: String] {
//        var value = self.bundleInfo.merging([], uniquingKeysWith: { $1 })
//        value[Keys.channelToken.rawValue] = playlist.channelToken
//        return value
//    }

    public init(playlist: Playlist, bundle: Bundle, environment: APEUnitEnvironment) throws {
//        guard !mediaId.isEmpty else {
//            throw APEUnitConfigurationError.invalidMediaId
//        }
        super.init(bundle: Bundle, environment: APEUnitEnvironment)
        self.playlist = playlist
    }

    public convenience init(playlist: Playlist, bundle: Bundle) throws {
        try self.init(playlist: playlist, bundle: bundle, environment: .production)
    }
}
