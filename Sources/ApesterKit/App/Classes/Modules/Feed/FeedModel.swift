//
//  FeedModel.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/7/22.
//
import Foundation
///
///
///
class FeedModel : NSObject , Decodable
{
    enum ItemType : String , Decodable
    {
        case ad
        case article
    }
    
    struct Article : Decodable, Hashable {
        let title      : String
        let subtitle   : String
        let image_link : String
        let link       : String
    }
    struct AdModel: Decodable, Hashable {
        let title: String
    }

    enum CodingKeys : String , CodingKey {
        case type
        case object
    }
    
    // MARK: - Properties
    let type    : ItemType
    let content : Decodable
    
    // MARK: - Init
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(ItemType.self, forKey: .type)
        
        switch type {
        case .ad     : content = try container.decode(AdModel.self, forKey: .object)
        case .article: content = try container.decode(Article.self, forKey: .object)
        }
    }
}
