//
//  FileMonitorProtocol.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/7/22.
//
import Foundation
///
/// Minimal interface all File Watchers have to implement.
///
public protocol FileMonitorProtocol {
    /**
     Starts observing file changes, a file watcher can only have one callback.
     
     - parameter closure: Closure to use for observations.
     
     - throws: `FileMonitor.Error`
     */
    func start(closure: @escaping FileMonitor.UpdateClosure) throws
    
    /**
     Stops observing file changes.
     
     - throws: `FileMonitor.Error`
     */
    func stop() throws
}
