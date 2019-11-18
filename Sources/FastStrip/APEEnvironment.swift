//
//  APEEnvironment.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 11/18/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

@objc public enum APEEnvironment: Int {
    case production, stage

    var baseUrl: String {
        var env: String
        switch self {
        case .production:
            env = ""
        case .stage:
            env = "stg."
        }
        return "https://faststrip." + env + "apester.com"
    }
}
