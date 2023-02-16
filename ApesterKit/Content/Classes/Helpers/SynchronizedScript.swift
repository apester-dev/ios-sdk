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

    private let queue = DispatchQueue(label: "com.synchronized-script.reader-writer.queue")

    private var nextUpdateData: Date {
        return Date(timeIntervalSinceNow: 0.05)
    }

    /// A poor man's mutex.
    private var count = 0

    /// Current run loop.
    private let runLoop = RunLoop.current

    /// Initializer.
    init() {}

    /// Lock the script runner.
    func lock() { queue.async { self.count += 1 }}

    /// Unlock the script runner.
    func unlock() { queue.async { self.count -= 1 }}

    /// Wait for all locks to unlock.
    func wait() { queue.async { while (self.count > 0 && self.runLoop.run(mode: .default, before: self.nextUpdateData)) {} }}
}
