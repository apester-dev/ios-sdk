//
//  APELog.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation
import Dispatch
import os

public class APELogger {
    
    // MARK: -  types
    public enum Severity: Int, CaseIterable, Comparable {
        
        case verbose = 0
        
        /// Reserved for caveman debugging
        case debug
        
        /// Used by the framework for information logging
        case info
        
        /// Errors are happening, but maybe recoverable
        case warning
        
        /// Everything is on fire
        case fatal
        
        case none
    }
    
    public struct Entry: CustomStringConvertible {
        
        public enum Payload: CustomStringConvertible {
            
            case message(String)
            case value(Any?)
            
            public var description: String {
                switch self {
                case .message(let text):
                    return text
                case .value(let value):
                    if let value = value {
                        return "\(value)"
                    }
                    return "<nil-value>"
                }
            }
        }
        
        public let payload: Payload
        
        public let formattedMetadata: String?
        
        public let severity: Severity
        
        public let file: String
        
        public let function: String
        
        public let line: Int
        
        public let timestamp: Date
        
        public let processName: String
        
        public let processID: Int32
        
        public var description: String {
            guard let metadata = formattedMetadata else {
                return payload.description
            }
            return "\(metadata) \(payload.description)"
        }
        
        public var message: String? {
            switch payload {
            case let .message(message):
                return message
            default:
                return nil
            }
        }
        
        public init(
            payload  : Payload,
            formattedMetadata: String? = nil,
            severity : APELogger.Severity,
            file     : String,
            function : String,
            line     : Int,
            timestamp: Date = Date()
        ) {
            self.payload     = payload
            self.formattedMetadata = formattedMetadata
            self.severity    = severity
            self.file        = file
            self.function    = function
            self.line        = line
            self.timestamp   = timestamp
            self.processName = APEProcessInfo.name
            self.processID   = APEProcessInfo.ID
        }
        
        func append(formattedMetadata newFormattedMetadata: String?) -> APELogger.Entry {
            guard let newFormattedMetadata = newFormattedMetadata?.trimmingCharacters(in: .whitespacesAndNewlines) else { return self }
            guard false == newFormattedMetadata.isEmpty else { return self }
            
            let new: String
            if let old = formattedMetadata, !old.isEmpty {
                new = "\(old) \(newFormattedMetadata)"
            }
            else {
                new = newFormattedMetadata
            }
            return APELogger.Entry(
                payload: payload,
                formattedMetadata: new,
                severity: severity,
                file: file,
                function: function,
                line: line,
                timestamp: timestamp
            )
        }
    }
    
    // MARK: -
    private init() {}
}

// MARK: - Log Channel
public extension APELogger {
    
    class Channel : APELogChannel {

        private let _stateLock : APEThreadMutex

        private var _enabled   : Bool
        private var _severity  : Severity
        private var _writer    : APELogWriter
        private var _formatter : APELogFormatter
        
        public convenience init(
            _ enabled  : Bool              ,
            _ severity : APELogger.Severity,
            _ writer   : APELogWriter      ,
            _ formatter: APELogFormatter
        ) {
            self.init(enabled: enabled, severity: severity, writer: writer, formatter: formatter)
        }
        public init(
            enabled  : Bool              ,
            severity : APELogger.Severity,
            writer   : APELogWriter      ,
            formatter: APELogFormatter
        ) {
            _stateLock = APEThreadMutex()
            _enabled   = enabled
            _severity  = severity
            _writer    = writer
            _formatter = formatter
        }

        @discardableResult
        private func synchronise<T>(block: () -> T) -> T {
            return _stateLock.withCriticalScope(block: block)
        }
        
        // MARK: - implemntation APELogChannel
        public var enabled   : Bool {
            get { return synchronise { _enabled } }
            set { synchronise { _enabled = newValue } }
        }
        public var severity  : Severity {
            get { return synchronise { _severity } }
            set { synchronise { _severity = newValue } }
        }
        public var writer    : APELogWriter {
            get { return synchronise { _writer } }
            set { synchronise { _writer = newValue } }
        }
        public var formatter : APELogFormatter {
            get { return synchronise { _formatter } }
            set { synchronise { _formatter = newValue } }
        }
    }
}

// MARK: - Log Writers

public extension APELogger {

    struct Writers {

        public static let standard : APELogWriter = {
            if #available(iOS 10.0, iOSApplicationExtension 10.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *) {
                return APELogger.Writers.APEOSLogWriter(log: .apester)
            }
            else {
                return APELogger.Writers.APEPrintLogWriter()
            }
        }()
    }
}

// MARK: - Log Formatters

public extension APELogger {

    struct Formatters {
        
        public static let standard: APELogFormatter = {
            return Concatenating([SeverityFormatter(), CallsiteFormatter()])
        }()
    }
}

// Implement Comparable for APELogger.Severity
public func < (lhs: APELogger.Severity, rhs: APELogger.Severity) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
