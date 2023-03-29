//
//  APEOSLogDestination.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 11/28/22.
//
import os.log
import Foundation
import XCGLogger
///
///
///
open class APEOSLogDestination: BaseQueuedDestination {
    
    private var _log: AnyObject?
    @available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)
    public var log: OSLog {
        get {
            return _log as? OSLog ?? OSLog.default
        }
        set {
            _log = newValue
        }
    }
    
    open override func output(logDetails: LogDetails, message: String) {
        var logDetails = logDetails
        var message = message
        
        // Apply filters, if any indicate we should drop the message, we abort before doing the actual logging
        if self.shouldExclude(logDetails: &logDetails, message: &message) {
            return
        }
        
        self.applyFormatters(logDetails: &logDetails, message: &message)
        
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%{public}@", log: log, type: logDetails.level.osLogType, message)
        } else {
            NSLog("%@", message)
        }
    }
}
@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)
extension XCGLogger.Level {
    var osLogType: OSLogType {
        switch self {
        case .info, .warning: /* warning as info, could be also error*/
            return .info
        case .error, .severe, .notice, .alert, .emergency:
            return .error
        case .debug, .verbose:
            return .debug
        case .none:
            return .default
        }
    }
}
