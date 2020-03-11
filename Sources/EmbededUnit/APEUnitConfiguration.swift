//
//  APEUnitConfiguration.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 10/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit

public enum APEUnitConfigurationError: Error {
    case invalidMediaId
}
                          
@objcMembers public class APEUnitConfiguration: NSObject {

    private enum Keys: String {
        case mediaId = "mediaId"
    }

    public private(set) var mediaId: String
    private(set) var bundleInfo: [String : String]
    private(set) var environment: APEUnitEnvironment

    private var parameters: [String: String] {
        var value = self.bundleInfo.merging([], uniquingKeysWith: { $1 })
        value[Keys.mediaId.rawValue] = mediaId
        return value
    }

    var unitURL: URL? {
        return self.parameters.componentsURL(baseURL: (self.environment.baseUrl + Constants.Unit.unitPath))
    }

    public init(mediaId: String, bundle: Bundle, environment: APEUnitEnvironment) throws {
        guard !mediaId.isEmpty else {
            throw APEUnitConfigurationError.invalidMediaId
        }
        self.mediaId = mediaId
        self.bundleInfo = BundleInfo.bundleInfoPayload(with: bundle)
        self.environment = environment
    }

    public convenience init(mediaId: String, bundle: Bundle) throws {
        try self.init(mediaId: mediaId, bundle: bundle, environment: .local)
    }
}
