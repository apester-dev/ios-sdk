//
//  APEEnvironment.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 11/18/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

@objc public enum APEEnvironment: Int {
    case production, stage, local, dev
    
    var stripBaseUrl: String {
        var env: String
        switch self {
        case .production:
            env = ""
        case .stage:
            env = "stg."
        case .local:
            return "https://strip-pwa.apester.local.com"
        case .dev:
            env = "stg."
        }
        return "https://faststrip." + env + "apester.com"
    }
    
    var unitBaseUrl: String {
        switch self {
        case .production:
            return "https://renderer.apester.com"
        case .stage:
            // return "https://renderer.stg.apester.dev"
            return "https://renderer.stg.apester.com"
        case .local:
            return "https://player.apester.local.com"
        case .dev:
            return "https://renderer.dayagi.apester.dev"
        }
    }
}
