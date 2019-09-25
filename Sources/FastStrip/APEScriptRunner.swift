//
//  APEScriptRunner.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/25/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

/// Helper for running Swift scripts with async callbacks.
class APEScriptRunner {

    private let queue = DispatchQueue(label: "com.ScriptRunner.reader-writer.queue", attributes: .concurrent)

    /// A poor man's mutex.
    private var count: Int {
        get {
            return queue.sync { state }
        }

        set (newState) {
            queue.async(flags: .barrier) { self.state = newState }
        }
    }

    private var state = 0

    /// Current run loop.
    private let runLoop = RunLoop.current

    /// Initializer.
    public init() {}

    /// Lock the script runner.
    func lock() {
        count += 1
    }

    /// Unlock the script runner.
    func unlock() {
        count -= 1
    }

    /// Wait for all locks to unlock.
    func wait() {
        while count > 0 &&
            runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.05)) {
        }
    }
}
