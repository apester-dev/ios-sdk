//
//  DemoLogWriter.swift
//  Apester
//
//  Created by Arkadi Yoskovitz on 1/9/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation
import ApesterKit

public class DemoLogWriter: APELogWriter {
    
    private let stateLock = DemoThreadMutex()
    private var _entries: [APELogger.Entry] = []
    
    public init() { }
    
    @discardableResult
    private func synchronise<T>(block: () -> T) -> T {
        return stateLock.withCriticalScope(block: block)
    }
    
    public var entries: [APELogger.Entry] {
        return synchronise { _entries }
    }
    
    public func write(entry: APELogger.Entry) {
        synchronise {
            _entries.append(entry)
        }
    }
}
