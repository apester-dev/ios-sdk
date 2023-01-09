//
//  APELogChannelExtensions.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

// MARK: - Protocol Exensions

public extension APELogChannel {

    func isEnabledFor(level: APELogger.Severity) -> Bool {
        guard enabled else { return false }
        return level >= self.severity
    }

    func write(entry: APELogger.Entry) {
        writer.write(entry: formatter.format(entry: entry))
    }
  
    private func logEntry(
        payload  : APELogger.Entry.Payload,
        severity : APELogger.Severity = .debug,
        file     : String = #file,
        function : String = #function,
        line     : Int    = #line
    ) {
        guard isEnabledFor(level: severity) else { return }
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)
        let entry = APELogger.Entry.init(
            payload  : payload,
            severity : severity,
            file     : file,
            function : function,
            line     : line,
            timestamp: Date()
        )
        write(entry: entry)
    }
    
    func logMessage(
        _ closure   : @autoclosure () -> Any?,
        severity    : APELogger.Severity,
        functionName: StaticString = #function,
        fileName    : StaticString = #file,
        lineNumber  : Int          = #line
    ) {
        guard let closureResult = closure() else { return }
        logEntry(
            payload  : .message(String(describing: closureResult)),
            severity : severity,
            file     : String(describing: fileName),
            function : String(describing: functionName),
            line     : lineNumber
        )
    }

    func logMessage(
        _ severity  : APELogger.Severity,
        functionName: StaticString = #function,
        fileName    : StaticString = #file,
        lineNumber  : Int          = #line,
        closure: () -> Any?
    ) {
        guard let closureResult = closure() else { return }
        logEntry(
            payload  : .message(String(describing: closureResult)),
            severity : severity,
            file     : String(describing: fileName),
            function : String(describing: functionName),
            line     : lineNumber
        )
    }
    
    func logValue(
        _ closure   : @autoclosure () -> Any?,
        severity    : APELogger.Severity ,
        functionName: StaticString = #function,
        fileName    : StaticString = #file,
        lineNumber  : Int          = #line
    ) {
        guard let closureResult = closure() else { return }
        logEntry(
            payload  : .value(closureResult),
            severity : severity,
            file     : String(describing: fileName),
            function : String(describing: functionName),
            line     : lineNumber
        )
    }

    func logValue(
        _ severity  : APELogger.Severity,
        functionName: StaticString = #function,
        fileName    : StaticString = #file,
        lineNumber  : Int          = #line,
        closure: () -> Any?
    ) {
        guard let closureResult = closure() else { return }
        logEntry(
            payload  : .value(closureResult),
            severity : severity,
            file     : String(describing: fileName),
            function : String(describing: functionName),
            line     : lineNumber
        )
    }
}
