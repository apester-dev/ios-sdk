//
//  APEStripLoadingState.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import CoreGraphics

// MARK:- APEStripLoadingState
struct APEStripLoadingState {
    var isLoaded = false
    var height: CGFloat = 10
    var isReady = false
    var initialMessage: String?
    var openUnitMessage: String?
}
