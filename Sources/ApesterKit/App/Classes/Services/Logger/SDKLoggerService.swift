//
//  SDKLoggerService.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 1/10/23.
//
import Foundation
import UIKit
import ApesterKit
import XCGLogger
///
///
///
final class SDKLoggerService : NSObject
{
    static func configure()
    {
        APELoggerService.shared.enabled = true
        APELoggerService.shared.formatter = APELogger.Formatters.Concatenating([
            APELogger.Formatters.standard,
            APELogger.Formatters.FunctionFormatter()
        ])
        APELoggerService.shared.writer = APELogger.Writers.Redirecting(writers: [
            APELogger.Writers.standard,
            XCGLogWriter()
        ])
    }
}
// MARK: - APEApplicationDelegateService
extension SDKLoggerService : APEApplicationDelegateService
{
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Self.configure()
        return true
    }
}
public class XCGLogWriter: APELogWriter {
    
    public init() { }
    
    public func write(entry: APELogger.Entry) {
    
        let level: XCGLogger.Level
        switch (entry.severity) {
        case .verbose: level = .verbose
        case .debug  : level = .debug
        case .info   : level = .info
        case .warning: level = .warning
        case .fatal  : level = .emergency
        case .none   : level = .none
        }
        logger.logln(
            level,
            functionName: entry.function,
            fileName	: entry.file,
            lineNumber  : entry.line,
            userInfo:  [:]) {
                return entry.description
            }
    }
}
