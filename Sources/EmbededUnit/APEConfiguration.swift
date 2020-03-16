//
//  APEConfiguration.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 16/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation

@objcMembers public class APEConfiguration: NSObject {
    
    private(set) var bundleInfo: [String : String]
    private(set) var environment: APEUnitEnvironment
    
    public init(bundle: Bundle, environment: APEUnitEnvironment) {
        
        self.bundleInfo = BundleInfo.bundleInfoPayload(with: bundle)
        self.environment = environment

    }
    
    private var parameters: [String: String] {
        var value = self.bundleInfo.merging([], uniquingKeysWith: { $1 })
//        value[Keys.mediaId.rawValue] = mediaId
        return value
    }
    
    var unitURL: URL? {
        return self.parameters.componentsURL(baseURL: (self.environment.baseUrl + Constants.Unit.unitPath))
    }

}
