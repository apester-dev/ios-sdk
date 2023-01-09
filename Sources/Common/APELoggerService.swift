//
//  APELoggerService.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 1/2/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import Foundation

/// Apester logger service
@objcMembers
public final class APELoggerService : NSObject {
    
    // MARK: - Static Properties
    public static let shared = APELoggerService()
    
    // MARK: - APELogChannels
    public private(set) var verbose: APELogChannel
    public private(set) var info   : APELogChannel
    public private(set) var debug  : APELogChannel
    public private(set) var warning: APELogChannel
    public private(set) var fatal  : APELogChannel
    
    private var noMessageClosure: () -> Any? = { return "" }
    
    // MARK: - Initialization
    private override init() {
        let e = true; let w = APELogger.Writers.standard; let f = APELogger.Formatters.standard
        self.enabled = e
        self.writer    = w
        self.formatter = f
        self.verbose = APELogger.Channel(enabled: e, severity: .verbose, writer: w, formatter: f)
        self.debug   = APELogger.Channel(enabled: e, severity: .debug  , writer: w, formatter: f)
        self.info    = APELogger.Channel(enabled: e, severity: .info   , writer: w, formatter: f)
        self.warning = APELogger.Channel(enabled: e, severity: .warning, writer: w, formatter: f)
        self.fatal   = APELogger.Channel(enabled: e, severity: .fatal  , writer: w, formatter: f)
    }
    
    private var channels: [APELogChannel] {
        return [verbose] //,debug,info,warning,fatal]
    }
    
    public var enabled: Bool {
        didSet {
            for var channel in channels {
                channel.enabled = enabled
            }
        }
    }
    
    public var writer: APELogWriter {
        didSet {
            for var channel in channels {
                channel.writer = writer
            }
        }
    }
    
    public var formatter: APELogFormatter {
        didSet {
            for var channel in channels {
                channel.formatter = formatter
            }
        }
    }
    
    // MARK: - Convenience logging methods
    
    // MARK: - verbose
    /// Log something at the Verbose log level. This format of verbose() isn't provided the object to log, instead the property *`noMessageClosure`* is executed instead.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func verbose(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: self.noMessageClosure)
    }
    
    /// Log something at the Verbose log level.
    ///
    /// - Parameters:
    ///     - closure:      A closure that returns the object to be logged.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - userInfo:     Dictionary for adding arbitrary data to the log message, can be used by filters/formatters etc
    ///
    /// - Returns:  Nothing.
    ///
    public func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    /// Log something at the Verbose log level.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - closure:      A closure that returns the object to be logged.
    ///
    /// - Returns:  Nothing.
    ///
    public func verbose(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> Any?) {
        self.logValue(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    // MARK: - Debug
    /// Log something at the Debug log level. This format of debug() isn't provided the object to log, instead the property *`noMessageClosure`* is executed instead.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func debug(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: self.noMessageClosure)
    }
    
    /// Log something at the Debug log level.
    ///
    /// - Parameters:
    ///     - closure:      A closure that returns the object to be logged.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    /// Log something at the Debug log level.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - closure:      A closure that returns the object to be logged.
    ///
    /// - Returns:  Nothing.
    ///
    public func debug(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> Any?) {
        self.logValue(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    // MARK: - Info
    /// Log something at the Info log level. This format of info() isn't provided the object to log, instead the property *`noMessageClosure`* is executed instead.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func info(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: self.noMessageClosure)
    }
    
    /// Log something at the Info log level.
    ///
    /// - Parameters:
    ///     - closure:      A closure that returns the object to be logged.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    /// Log something at the Info log level.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - closure:      A closure that returns the object to be logged.
    ///
    /// - Returns:  Nothing.
    ///
    public func info(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> Any?) {
        self.logValue(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    // MARK: - Warning
    /// Log something at the Warning log level. This format of warning() isn't provided the object to log, instead the property *`noMessageClosure`* is executed instead.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func warning(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: self.noMessageClosure)
    }
    
    /// Log something at the Warning log level.
    ///
    /// - Parameters:
    ///     - closure:      A closure that returns the object to be logged.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func warning(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    /// Log something at the Warning log level.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - closure:      A closure that returns the object to be logged.
    ///
    /// - Returns:  Nothing.
    ///
    public func warning(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> Any?) {
        self.logValue(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    // MARK: - Fatal
    /// Log something at the Fatal log level. This format of fatal() isn't provided the object to log, instead the property *`noMessageClosure`* is executed instead.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func fatal(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.fatal, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: self.noMessageClosure)
    }
    
    /// Log something at the Fatal log level.
    ///
    /// - Parameters:
    ///     - closure:      A closure that returns the object to be logged.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///
    /// - Returns:  Nothing.
    ///
    public func fatal(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logValue(.fatal, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    /// Log something at the Fatal log level.
    ///
    /// - Parameters:
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - closure:      A closure that returns the object to be logged.
    ///
    /// - Returns:  Nothing.
    ///
    public func fatal(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> Any?) {
        self.logValue(.fatal, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }
    
    private func logValue(
        _ severity  : APELogger.Severity,
        functionName: StaticString = #function,
        fileName    : StaticString = #file,
        lineNumber  : Int          = #line,
        closure: () -> Any?
    ) {
        channels.forEach { channel in
            channel.logValue(severity, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        }
    }
}
