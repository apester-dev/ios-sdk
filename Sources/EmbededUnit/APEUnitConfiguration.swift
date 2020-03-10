//
//  APEUnitConfiguration.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 10/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit

public enum AlmogError: Error {
    case invalidChannelToken
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
            throw AlmogError.invalidChannelToken
        }
        self.mediaId = mediaId
        self.bundleInfo = BundleInfo.bundleInfoPayload(with: bundle)
        self.environment = environment
    }

    public convenience init(mediaId: String, bundle: Bundle) throws {
        try self.init(mediaId: mediaId, bundle: bundle, environment: .local)
    }
}

// MARK:- Dictionary Extension
private extension Dictionary {
    func componentsURL(baseURL urlString: String) -> URL? {
        var components = URLComponents(string: urlString)
        components?.queryItems = self.compactMap { (arg) in
            guard let key = arg.key as? String, let value = arg.value as? String else {
                return nil
            }
            return URLQueryItem(name: key, value: value)
        }
        return components?.url
    }
}
