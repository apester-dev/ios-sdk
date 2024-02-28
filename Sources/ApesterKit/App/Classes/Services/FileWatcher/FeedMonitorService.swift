//
//  FeedMonitorService.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import UIKit
///
///
///
protocol FeedChangeListener : AnyObject {
    func feedMonitorService(_ : FeedMonitorService, onDataChange data: Data)
}
///
///
///
final class FeedMonitorService : NSObject
{
    var feedFilePath : String {
#if targetEnvironment(simulator)
        "/Users/\(FileMonitor.Local.simulatorOwnerUsername())/Desktop/apester.json"
#else
        "https://pastebin.com/raw/rGRf35uz"
#endif
    }
    
    var feedFileLocation : URL {
#if targetEnvironment(simulator)
        let path = feedFilePath
        if !FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            try? "{}".data(using: .utf8)?.write(to: url, options: .atomic)
        }
#endif
        return URL(string: feedFilePath)!
    }
    
    var feedFileMonitor  : FileMonitorProtocol {
#if targetEnvironment(simulator)
        FileMonitor.Local .init(url: feedFileLocation)
#else
        FileMonitor.Remote.init(url: feedFileLocation)
#endif
    }
    
    var currentFeedData: Data! {
        didSet {
            delegate?.feedMonitorService(self, onDataChange: currentFeedData)
        }
    }
    
    weak var delegate: FeedChangeListener? {
        didSet {
            delegate?.feedMonitorService(self, onDataChange: currentFeedData)
        }
    }
    
    override init() {
        delegate = nil
        super.init()
    }
    
    func activateMonitor() {
        do {
            try feedFileMonitor.start { refreshResult in
                
                switch refreshResult {
                case .noChanges:
                    break
                case .updated(let data):
                    self.currentFeedData = data
                }
            }
        }
        catch (let error) {
            logger.error("Unable to retrive feed monitor information, error: \(error)")
        }
    }
}
// MARK: - APEApplicationDelegateService
extension FeedMonitorService : APEApplicationDelegateService
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        activateMonitor()
        return true
    }
}
