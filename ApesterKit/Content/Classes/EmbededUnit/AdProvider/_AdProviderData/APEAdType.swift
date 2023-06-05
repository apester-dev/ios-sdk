//
//  APEAdType.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//

import Foundation

enum APEAdType : String , CustomStringConvertible
{
    case bottom    = "bottom"
    case inUnit    = "inUnit"
    case companion = "companion"
    
    var supportedSizes: [APEAdSize] {
        switch self {
        case .bottom: return [.adSize320x50]
        case .inUnit: return [.adSize300x250]
        case .companion: return [.adSize300x250, .adSize320x50]
        }
    }
    
    var description : String { return rawValue }
}
