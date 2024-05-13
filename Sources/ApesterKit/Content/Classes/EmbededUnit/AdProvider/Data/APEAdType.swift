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
    case inUnit    = "inUnit"
    case bottom    = "bottom"
    case companion = "companion"
    case inUnitVideo = "inUnitVideo"
    case interstitial = "interstitial"
    
    internal var supportedSizes: [APEAdSize] {
        switch self {
        case .inUnit, .inUnitVideo: return [.adSize300x250]
        case .bottom: return [.adSize320x50]
        case .companion: return [.adSize300x250, .adSize320x50]
        case .interstitial: return [.adSize320x480]
        
        }
    }
    
    internal var description : String { return rawValue }
}
