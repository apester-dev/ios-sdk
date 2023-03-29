//
//  APEProcessInfo.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

internal struct APEProcessInfo {

    static var name: String {
        return shared.name
    }

    static var ID: Int32 {
        return shared.ID
    }

    private static let shared = APEProcessInfo()

    private let name: String
    private let ID: Int32

    private init() {
        let process = ProcessInfo.processInfo
        self.ID   = process.processIdentifier
        self.name = process.processName
    }
}
