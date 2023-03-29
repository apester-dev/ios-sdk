//
//  FileMonitorRemote.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/7/22.
//
import Foundation
///
///
///
public extension FileMonitor {
    
    /// Watcher for remote files, it supports both ETag and Last-Modified HTTP header tags.
    final class Remote : FileMonitorProtocol {
        
        private enum State {
            case started(sessionHandler: URLSessionHandler, timer: Timer)
            case stopped
        }
        
        fileprivate struct Constants {
            static let IfModifiedSinceKey = "If-Modified-Since"
            static let LastModifiedKey    = "Last-Modified"
            static let IfNoneMatchKey     = "If-None-Match"
            static let ETagKey            = "Etag"
        }
        
        internal static var sessionConfiguration: URLSessionConfiguration = {
            
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            return config
        }()
        
        
        /// URL that this watcher is observing.
        let url : URL
        
        /// The minimal amount of time between querying the `url` again.
        let refreshInterval : TimeInterval
        
        private var state : State = .stopped
        
        /**
         Creates a new watcher using given URL and refreshInterval.
         
         - parameter url:             URL to observe.
         - parameter refreshInterval: Minimal refresh interval between queries.
         */
        public init(url: URL, refreshInterval: TimeInterval = 1) {
            
            self.url = url
            self.refreshInterval = refreshInterval
        }
        
        deinit {
            _ = try? stop()
        }
        
        public func start(closure: @escaping FileMonitor.UpdateClosure) throws {
            
            guard case .stopped = state else {
                throw FileMonitor.Error.alreadyStarted
            }
            
            let timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
            
            state = .started(sessionHandler: URLSessionHandler(url: url, sessionConfiguration: FileMonitor.Remote.sessionConfiguration, callback: closure), timer: timer)
            
            timer.fire()
        }
        
        public func stop() throws {
            
            guard case let .started(_, timer) = state else { return }
            timer.invalidate()
            state = .stopped
        }
        
        /**
         Force refresh, can only be used if the watcher was started.
         
         - throws: `FileWatcher.Error.notStarted`
         */
        @objc public func refresh() throws {
            
            guard case let .started(handler, _) = state else { throw Error.notStarted }
            handler.refresh()
        }
    }
}
///
///
///
public extension FileMonitor.Remote {
    
    final class URLSessionHandler : NSObject, URLSessionDelegate, URLSessionDownloadDelegate
    {
        private var task         : URLSessionDownloadTask?
        private var lastModified : String
        private var lastETag     : String
        
        private let callback : FileMonitor.UpdateClosure
        private let url : URL
        
        private lazy var session : URLSession = {
            return URLSession(configuration: self.configuration, delegate: self, delegateQueue: self.processingQueue)
        }()
        
        private let processingQueue : OperationQueue = {
            return OperationQueue.generateBackgroundQueue()
        }()

        private let configuration : URLSessionConfiguration
        
        init(
            url : URL, sessionConfiguration : URLSessionConfiguration, callback : @escaping FileMonitor.UpdateClosure
        ) {
            self.task         = nil
            self.lastModified = String()
            self.lastETag     = String()
            self.configuration = sessionConfiguration
            self.callback = callback
            self.url      = url
            super.init()
        }
        
        deinit {
            processingQueue.cancelAllOperations()
        }
        
        func refresh() {
            
            processingQueue.addOperation { [weak self] in
                
                guard let strongSelf = self else { return }
                
                var request = URLRequest(url: strongSelf.url)
                request.setValue(strongSelf.lastModified, forHTTPHeaderField: Constants.IfModifiedSinceKey)
                request.setValue(strongSelf.lastETag    , forHTTPHeaderField: Constants.IfNoneMatchKey)
                
                strongSelf.task = strongSelf.session.downloadTask(with: request)
                strongSelf.task?.resume()
            }
        }
        
        public func urlSession(
            _ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL
        ) {
            
            guard let response = downloadTask.response as? HTTPURLResponse else {
                assertionFailure("expected HTTPURLResponse received \(String(describing: downloadTask.response))")
                task = nil
                return
            }
            
            if response.statusCode == 304 {
                callback(.noChanges)
                task = nil
                return
            }
            
            if let modified = response.allHeaderFields[Constants.LastModifiedKey] as? String {
                lastModified = modified
            }
            
            if let etag = response.allHeaderFields[Constants.ETagKey] as? String {
                lastETag = etag
            }
            
            guard let data = try? Data(contentsOf: location) else {
                assertionFailure("can't load data from URL \(location)")
                return
            }
            
            callback(.updated(data: data))
            task = nil
        }
    }
}
