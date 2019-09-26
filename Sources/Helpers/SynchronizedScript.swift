//
//  SynchronizedScript.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/25/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

/// Helper for running Swift scripts with async callbacks.
class SynchronizedScript {

    private var nextUpdateData: Date {
        return Date(timeIntervalSinceNow: 0.05)
    }

    /// A poor man's mutex.
    private var count = SynchronizedProperty(0)

    /// Current run loop.
    private let runLoop = RunLoop.current

    /// Initializer.
    init() {}

    /// Lock the script runner.
    func lock() { count.value += 1 }

    /// Unlock the script runner.
    func unlock() { count.value -= 1 }

    /// Wait for all locks to unlock.
    func wait() { while (count.value > 0 && runLoop.run(mode: .default, before: nextUpdateData)) {} }
}
