//
//  APEThreadMutex.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

/// A wrapper class for a pthread_mutex
internal final class APEThreadMutex {
    private var mutex = pthread_mutex_t()

    public init() {
        let result = pthread_mutex_init(&mutex, nil)
        precondition(result == 0, "Failed to create pthread mutex")
    }

    deinit {
        let result = pthread_mutex_destroy(&mutex)
        assert(result == 0, "Failed to destroy mutex")
    }

    fileprivate func lock() {
        let result = pthread_mutex_lock(&mutex)
        assert(result == 0, "Failed to lock mutex")
    }

    fileprivate func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        assert(result == 0, "Failed to unlock mutex")
    }

    /// Convenience API to execute block after acquiring the lock
    ///
    /// - Parameter block: the block to run
    /// - Returns: returns the return value of the block
    public func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        defer { unlock() }
        let value = block()
        return value
    }
}
