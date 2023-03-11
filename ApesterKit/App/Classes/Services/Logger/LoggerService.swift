//
//  LoggerService.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//
import UIKit
import XCGLogger
///
///
///
let logIdentifierGeneral = Bundle.main.bundleIdentifier! + ".Logger"
let logger = XCGLogger(identifier: logIdentifierGeneral, includeDefaultDestinations: false)
///
///
///
final class LoggerService : NSObject
{
    class DestinationFactory
    {
        var owner: XCGLogger
        
        fileprivate init(owner: XCGLogger)
        {
            self.owner = owner
        }
        
        func createSystem(identifier: String) -> DestinationProtocol
        {
            let destination = APEOSLogDestination(owner: logger, identifier: identifier)
            destination.outputLevel       = .debug
            destination.showLogIdentifier = false
            destination.showFunctionName  = true
            destination.showThreadName    = true
            destination.showLevel         = true
            destination.showFileName      = true
            destination.showLineNumber    = true
            destination.showDate = false
            destination.logQueue = DispatchQueue(label: identifier)
            destination.log      = OSLogs.Apester
            
            return destination
        }
    }
    
    static func configure()
    {
        let destination = DestinationFactory(owner: logger).createSystem(identifier: "systemLogger")
        
        // Add the destination to the logger
        logger.add(destination: destination)
        
        // Add basic app info, version info etc, to the start of the logs
        logger.logAppDetails()
    }
}
// MARK: - APEApplicationDelegateService
extension LoggerService : APEApplicationDelegateService
{
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Self.configure()
        return true
    }
}
