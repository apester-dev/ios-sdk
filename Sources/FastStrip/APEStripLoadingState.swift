//
//  APEStripLoadingState.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

// MARK:- APEStripLoadingState
struct APEStripLoadingState {
    var isLoaded = false
    var height: Float = 0
    var isReady = false
    var initialMessage: String?
    var openUnitMessage: String?
}
