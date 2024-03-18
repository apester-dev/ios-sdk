//
//  enums.swift
//  ApesterKit_Example
//
//  Created by Michael Krotorio on 1/25/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

enum UnitType {
    case Poll, Story,Quiz, Playlist
}

enum Category: String {
    case lifestyle = "Lifestyle"
    case news = "News"
    case sports = "Sports"
}

enum Environment: String {
    case PROD = "Production"
    case STAGE = "Staging"
    case DEV = "Dev"
}

