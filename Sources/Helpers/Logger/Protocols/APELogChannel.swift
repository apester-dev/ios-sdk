//
//  APELogChannel.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

public protocol APELogChannel {
    var enabled  : Bool               { get set }
    var severity : APELogger.Severity { get set }
    var writer   : APELogWriter       { get set }
    var formatter: APELogFormatter    { get set }
}
