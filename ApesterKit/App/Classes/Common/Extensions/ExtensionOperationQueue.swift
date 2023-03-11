//
//  ExtensionOperationQueue.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/5/22.
//
import Foundation
///
///
///
extension OperationQueue {
    
    class func generateBackgroundQueue() -> OperationQueue {
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}
