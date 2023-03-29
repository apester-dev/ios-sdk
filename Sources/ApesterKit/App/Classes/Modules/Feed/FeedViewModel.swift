//
//  FeedViewModel.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import Foundation
///
///
///
protocol FeedViewModelDelegate : AnyObject
{
    func didUpdateInformation()
}
///
///
///
final class FeedViewModel: ViewModel
{
    struct Parser
    {
        func parse(from data: Data) -> [FeedModel] {
            logger.debug()
            
            var results = [FeedModel]()
            guard let rawJSON = try? JSONSerialization.jsonObject(with: data, options: []) else { return results }
            guard let rawDictanary = rawJSON as? [String : Any] else { return results }
            guard let result = rawDictanary["data"]   as? [Any] else { return results }
                
            guard let rawFeed = try? JSONSerialization.data(withJSONObject: result, options: []) else { return results }
            guard let models = try? JSONDecoder().decode([FeedModel].self, from: rawFeed)        else { return results }
            results.append(contentsOf: models)
            return results
        }
    }
    
    // MARK: - Properties
    typealias Item = FeedModel
    /// The elements in the section.
    private var content : [FeedModel]
    
    ///
    weak var delegate : FeedViewModelDelegate?
    
    ///
    unowned let environmentData : EnvironmentModel
    
    ///
    internal var itemsCount: Int { count }
    
    // MARK: - Properties
    init(
        environment : EnvironmentModel
    ) {
        self.environmentData = environment
        self.content         = [FeedModel]()
        AppDelegate.shared.fileWatcherService.delegate = self
    }
}
///
///
///
extension FeedViewModel : OrderedCollection
{
    var isEmpty : Bool { count == 0 }
    var   count : Int  { content.count }
    
    func item(at location: Int) -> FeedModel?
    {
        guard location < content.count else { return nil }
        return content[location]
    }
}
///
///
///
extension FeedViewModel : FeedChangeListener
{
    func feedMonitorService(_: FeedMonitorService, onDataChange data: Data) {
        logger.debug()
        
        let parsed = Parser.init().parse(from: data)
        content.removeAll()
        content.append(contentsOf: parsed)
        
        delegate?.didUpdateInformation()
    }
}
