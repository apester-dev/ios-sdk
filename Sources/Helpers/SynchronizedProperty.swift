//
//  SynchronizedProperty.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/26/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

class SynchronizedProperty<T> {

    private let queue = DispatchQueue(label: "com.synchronized-property.reader-writer.queue", attributes: .concurrent)

    private var internalValue: T

    /// A poor man's mutex.
    var value: T {
        get {
            return queue.sync { internalValue }
        }

        set (newState) {
            queue.async(flags: .barrier) { self.internalValue = newState }
        }
    }

    init(_ value: T) {
        self.internalValue = value
    }
}
