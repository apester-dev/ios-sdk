//
//  ExtensionOSLog.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 11/28/22.
//
import Foundation
import OSLog
///
///
///
class OSLogs {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Logs Apster content
    static let Apester = OSLog(subsystem: subsystem, category: "Apester")
}
