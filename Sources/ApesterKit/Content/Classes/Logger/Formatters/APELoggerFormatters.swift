//
//  APELoggerFormatters.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

// MARK: - Log Formatters

public extension APELogger.Formatters {

    class Concatenating: APELogFormatter {
        
        public let formatters: [APELogFormatter]

        public init(_ formatters: [APELogFormatter]) {
            self.formatters = formatters
        }

        public func format(entry: APELogger.Entry) -> APELogger.Entry {
            return formatters.reduce(entry) { $1.format(entry: $0) }
        }
    }

    class SeverityFormatter: APELogFormatter {

        public func format(entry: APELogger.Entry) -> APELogger.Entry {
            return entry.append(formattedMetadata: entry.severity.description)
        }
    }

    class StaticStringFormatter: APELogFormatter {

        public let text: String

        public init(_ text: String) {
            self.text = text
        }

        public func format(entry: APELogger.Entry) -> APELogger.Entry {
            return entry.append(formattedMetadata: text)
        }
    }

    class CallsiteFormatter: APELogFormatter {
        
        public func format(entry: APELogger.Entry) -> APELogger.Entry {
            guard entry.file.contains("APE") else { return entry }
            let filename = (entry.file as NSString).pathComponents.last ?? "redacted"
            return entry.append(formattedMetadata: "\(filename):\(entry.line)")
        }
    }
    class FunctionFormatter : APELogFormatter {
        
        public init() {}
        public func format(entry: APELogger.Entry) -> APELogger.Entry {
            guard entry.file.contains("APE") else { return entry }
            return entry.append(formattedMetadata: "\(entry.function)")
        }
    }
}

extension APELogger.Severity: CustomStringConvertible {

    public var description: String {
        switch self {
        case .verbose:
            return "▪️"
        case .info:
            return "🔷"
        case .debug:
            return "◽️"
        case .warning:
            return "⚠️"
        case .fatal:
            return "❌"
        default:
            return ""
        }
    }
}

