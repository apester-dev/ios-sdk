//
//  AppDelegate.swift
//  Apester
//
//  Created by Hasan Sa on 28/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import ApesterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // initiate StripConfigurationsFactory environment
        StripConfigurationsFactory.environment = .stage
        // preloadStripViews
        // APEViewService.shared.preloadStripViews(with: StripConfigurationsFactory.configurations(hideApesterAds: false))
        // initiate UnitConfigurationsFactory environment
        UnitConfigurationsFactory.environment = .dev
        // preloadUnitViews
        // APEViewService.shared.preloadUnitViews(with: UnitConfigurationsFactory.configurations(hideApesterAds: false))
        APELoggerService.shared.enabled = true
        APELoggerService.shared.formatter = APELogger.Formatters.Concatenating([
            APELogger.Formatters.standard,
            APELogger.Formatters.FunctionFormatter()
        ])
        APELoggerService.shared.writer = APELogger.Writers.Redirecting(writers: [
            APELogger.Writers.standard,
            DemoLogWriter()
        ])
        
        APELoggerService.shared.info { "something logged 1" }
        
        APELoggerService.shared.debug { "something logged 2" }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
public class DemoLogWriter: APELogWriter {
    
    private let stateLock = DemoThreadMutex()
    private var _entries: [APELogger.Entry] = []
    
    public init() { }
    
    @discardableResult
    private func synchronise<T>(block: () -> T) -> T {
        return stateLock.withCriticalScope(block: block)
    }
    
    public var entries: [APELogger.Entry] {
        return synchronise { _entries }
    }
    
    public func write(entry: APELogger.Entry) {
        synchronise {
            _entries.append(entry)
        }
    }
}
/// A wrapper class for a pthread_mutex
internal final class DemoThreadMutex {
    private var mutex = pthread_mutex_t()
    
    public init() {
        let result = pthread_mutex_init(&mutex, nil)
        precondition(result == 0, "Failed to create pthread mutex")
    }
    
    deinit {
        let result = pthread_mutex_destroy(&mutex)
        assert(result == 0, "Failed to destroy mutex")
    }
    
    fileprivate func lock() {
        let result = pthread_mutex_lock(&mutex)
        assert(result == 0, "Failed to lock mutex")
    }
    
    fileprivate func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        assert(result == 0, "Failed to unlock mutex")
    }
    
    /// Convenience API to execute block after acquiring the lock
    ///
    /// - Parameter block: the block to run
    /// - Returns: returns the return value of the block
    public func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        defer { unlock() }
        let value = block()
        return value
    }
}
