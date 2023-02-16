//
//  APELogFormatter.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

public protocol APELogFormatter {

    func format(entry: APELogger.Entry) -> APELogger.Entry
}

