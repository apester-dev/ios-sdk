//
//  APEAdType.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//
import Foundation
///
///
///
internal enum APEAdType : String , CustomStringConvertible
{
    case inUnit         = "inUnit"
    case bottom         = "bottom"
    case companion      = "companion"
    case inUnitVideo    = "inUnitVideo"
    
    internal var supportedSizes: [APEAdSize] {
        switch self {
        case .inUnit: return [.adSize300x250]
        case .bottom: return [.adSize320x50]
        case .companion: return [.adSize300x250, .adSize320x50]
        case .inUnitVideo: return [.adSize300x250]
        }
    }
    
    internal var description : String { return rawValue }
}
