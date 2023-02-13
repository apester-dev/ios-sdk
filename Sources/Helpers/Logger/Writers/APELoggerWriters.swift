//
//  APELoggerWriters.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation
import os

// MARK: - Log Writer

// MARK: - OSLog Writer

@available(iOS 10.0, iOSApplicationExtension 10.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *)
public extension APELogger.Severity {

    var logType: OSLogType {
        switch self {
        case .verbose, .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .fatal:
            return .error
        case .none:
            return .default
        }
    }
}

extension APELogger.Writers {

    @available(iOS 10.0, iOSApplicationExtension 10.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *)
    public class APEOSLogWriter: APELogWriter {

        public let log: OSLog

        public init(log: OSLog) {
            self.log = log
        }

        public func write(entry: APELogger.Entry) {
            os_log("%{public}@", log: log, type: entry.severity.logType, entry.description)
        }
    }
}

@available(iOS 10.0, iOSApplicationExtension 10.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *)
internal extension OSLog {

    static let apester = OSLog(subsystem: "com.apester", category: "ApesterKit")
}


// MARK: - Print Log Writer

extension APELogger.Writers {

    public class APEPrintLogWriter: APELogWriter {

        public func write(entry: APELogger.Entry) {
            print(entry)
        }
    }
}

extension APELogger.Writers {

    public class Redirecting: APELogWriter {

        public let writers: [APELogWriter]

        public init(writers: [APELogWriter]) {
            self.writers = writers
        }

        public func write(entry: APELogger.Entry) {
            writers.forEach { $0.write(entry: entry) }
        }
    }
}
