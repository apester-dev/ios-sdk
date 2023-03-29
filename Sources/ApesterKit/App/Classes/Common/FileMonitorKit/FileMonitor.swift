//
//  FileMonitor.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/7/22.
//
import Foundation
///
///
///
public enum FileMonitor {
    
    /// Errors that can be thrown from `FileMonitorProtocol`.
    public enum Error: Swift.Error {
        
        /// Trying to perform operation on watcher that requires started state.
        case notStarted
        
        /// Trying to start watcher that's already running.
        case alreadyStarted
        
        /// Trying to stop watcher that's already stopped.
        case alreadyStopped
        
        /// Failed to start the watcher, `reason` will contain more information why.
        case failedToStart(reason: String)
    }
    
    /// Enum that contains status of refresh result.
    public enum RefreshResult {
        /// Watched file didn't change since last update.
        case noChanges
        
        /// Watched file did change.
        case updated(data: Data)
    }
    
    /// Closure used for File watcher updates.
    public typealias UpdateClosure = (RefreshResult) -> Void
}

extension FileMonitor.Error : CustomStringConvertible {
    public var description: String {
        switch self {
        case .notStarted    : return "Not Started"
        case .alreadyStarted: return "Already Started"
        case .alreadyStopped: return "Already Stopped"
        case let .failedToStart(reason): return "Failed To Start due: \(reason)"
        }
    }
}
