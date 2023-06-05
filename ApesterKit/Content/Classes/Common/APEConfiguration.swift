//
//  APEConfiguration.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 3/19/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation

@objc(APEConfiguration)
@objcMembers public class APEConfiguration: NSObject {
    let bundleInfo: [String : String]
    let environment: APEEnvironment

    var parameters: [String: String] { self.bundleInfo.merging([], uniquingKeysWith: { $1 }) }
    public init(bundle: Bundle, environment: APEEnvironment) {
        self.bundleInfo = BundleInfo.bundleInfoPayload(with: bundle)
        self.environment = environment
    }
}
