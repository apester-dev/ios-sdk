//
//  APELogWriter.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

public protocol APELogWriter {

    func write(entry: APELogger.Entry)
}
