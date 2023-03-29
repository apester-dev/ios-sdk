//
//  APEMonetization.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//
import Foundation
///
///
///
enum APEMonetization : Equatable
{
    case adMob   (params: APEAdParameters)
    case pubMatic(params: APEAdParameters)
    case amazon  (params: APEAdParameters)
    
    var identifier : String {
        switch self {
        case .adMob   (let p): return p.identifier
        case .pubMatic(let p): return p.identifier
        case .amazon  (let p): return p.identifier
        }
    }
    var isCompanionVariant: Bool {
        switch self {
        case .adMob   (let p): return p.isVariant
        case .pubMatic(let p): return p.isVariant
        case .amazon  (let p): return p.isVariant
        }
    }
    var adType: APEAdType {
        switch self {
        case .adMob   (let p): return p.type
        case .pubMatic(let p): return p.type
        case .amazon  (let p): return p.type
        }
    }
}

func == (lhs: APEMonetization, rhs: APEMonetization) -> Bool {
    switch (lhs, rhs) {
    case (.adMob   (let l), .adMob   (let r)): return l.identifier == r.identifier && l.type == r.type
    case (.pubMatic(let l), .pubMatic(let r)): return l.identifier == r.identifier && l.type == r.type
    case (.amazon  (let l), .amazon  (let r)): return l.identifier == r.identifier && l.type == r.type
    default: return false
    }
}
