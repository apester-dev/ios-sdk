//
//  unit_structs.swift
//  ApesterKit_Example
//
//  Created by Michael Krotorio on 1/25/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

struct ScreenContent {
    let unitType: UnitType
    let mediaId: String
    let article: Article

}

struct Article {
    let title: String
    let topArticle: String
    let bottomArticle: String
}
