//
//  EnvironmentViewModel.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/5/22.
//
import Foundation
import ApesterKit
///
///
///
class EnvironmentViewModel : NSObject , ViewModel
{
    // MARK: - Keys
    enum EncodingKeys : String , CustomStringConvertible
    {
        case persistence
        var description : String { self.rawValue }
    }
    
    // MARK: - properties
    var model: EnvironmentModel
    
    // MARK: -
    init(
        modelObject: EnvironmentModel? = nil
    ) {
        let m = modelObject ?? Self.load() ?? EnvironmentModel.init()
        self.model = m
        super.init()
    }
    
    func update(gdpr input: String)
    {
        model.gdprToken = input
    }
    func update(token input: String)
    {
        model.token = input
    }
    func update(mediaID input: String)
    {
        model.mediaID = input
    }
    func update(environment input: APEEnvironment)
    {
        model.environment = input
    }
    
    func save()
    {
        logger.debug()
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: EncodingKeys.persistence.description)
            UserDefaults.standard.synchronize()
        }
        catch let e {
            logger.error("error: \(e)")
        }
    }
    
    static func load() -> EnvironmentModel?
    {
        logger.debug()
        
        let defaults = UserDefaults.standard
        if defaults.dictionaryRepresentation().keys.contains(EncodingKeys.persistence.description) {
            
            if let data = defaults.data(forKey: EncodingKeys.persistence.description)
            {
                let info = try? NSKeyedUnarchiver.unarchivedObject(ofClass: EnvironmentModel.self, from: data)
                return info
            }
        }
        return nil
    }
}
///
///
///
extension EnvironmentViewModel
{
    var    gdpr : String? { model.gdprToken }
    var   token : String { model.token   }
    var mediaID : String { model.mediaID }
    var environment : APEEnvironment { model.environment }
}
