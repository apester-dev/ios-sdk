//
//  APEUnitEnviorment.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 10/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation

@objc public enum APEUnitEnvironment: Int {
    case production, stage, local

    var baseUrl: String {
        var env: String
        switch self {
        case .production:
            env = ""
        case .stage:
            env = "stg."
        case .local:
            return "https://player.apester.local.com"
        }
        return "https://renderer.\(env).apester.com"
    }
}
