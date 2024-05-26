//
//  APEEnvironment.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 11/18/19.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
///
///
///
@objc(APEEnvironment)
public enum APEEnvironment: Int
{
    case production
    case stage
    case dev
    
    var stripBaseUrl: String
    {
        var env: String
        switch self {
        case .production:
            env = ""
        case .stage:
            env = "stg."
        case .dev:
            env = "stg."
        }
        return "https://faststrip." + env + "apester.com"
    }
    
    var unitBaseUrl: String
    {
        switch self {
        case .production:
            return "https://renderer.apester.com"
        case .stage:
            // return "https://renderer.stg.apester.dev"
            return "https://renderer.stg.apester.dev"
        case .dev:
            return "https://renderer.dayagi.apester.dev"
        }
    }
}
