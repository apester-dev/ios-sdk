//
//  EnvironmentModel.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/5/22.
//
import Foundation
import ApesterKit
///
/// A data object representing the current configuration setup of ApesterKit
///
class EnvironmentModel : NSObject , ViewModel, NSCoding , NSSecureCoding
{
    // MARK: - Keys
    enum EncodingKeys : String , CustomStringConvertible
    {
        case environment
        case gdpr
        case token
        case mediaID
        
        var description: String { self.rawValue }
    }
    
    // MARK: - Properties
    var environment : APEEnvironment
    var gdprToken   : String?
    var   token : String
    var mediaID : String
    
    static var supportsSecureCoding: Bool { true }
    // MARK: - Init
    init(
        environment  : APEEnvironment = APEEnvironment.dev,
        mediaIDString: String = String(),
        tokenString  : String = String(),
        gdprString   : String? = nil
    ) {
        self.environment = environment
        self.gdprToken   = gdprString
        self.mediaID = mediaIDString
        self.token   = tokenString
        super.init()
    }
    
    // MARK: - NSCoding
    required init?(coder: NSCoder)
    {
        let i = coder.decodeInteger(forKey: EncodingKeys.environment.description)
        self.environment = Self.environment(for: i)
        self.gdprToken  = coder.decodeObject(forKey: EncodingKeys.gdpr.description) as? String
        self.token   = coder.decodeObject(forKey: EncodingKeys.token  .description) as? String ?? String()
        self.mediaID = coder.decodeObject(forKey: EncodingKeys.mediaID.description) as? String ?? String()
        super.init()
    }
    func encode(with coder: NSCoder)
    {
        coder.encode(Self.index(for: environment), forKey: EncodingKeys.environment.description)
        if let gdprToken = gdprToken {
            coder.encode(gdprToken, forKey: EncodingKeys.gdpr.description)            
        }
        coder.encode(token    , forKey: EncodingKeys.token  .description)
        coder.encode(mediaID  , forKey: EncodingKeys.mediaID.description)
    }
    
    // MARK: -
    static private func index(for environment: APEEnvironment) -> Int
    {
        switch environment {
        case .production: return 0
        case .stage     : return 1
        case .local     : return 2
        case .dev       : return 3
        }
    }
    static private func environment(for index: Int) -> APEEnvironment
    {
        switch index {
        case 0  : return .production
        case 1  : return .stage
        case 2  : return .local
        default : return .dev
        }
    }
    
    // MARK: -
    var unitIdentifiers : [String] { unitParameters.map(\.id) }
    var unitParameters  : [APEUnitParams] {
        
        var group = [APEUnitParams]()
        if !token  .isEmpty { group.append(.playlist(tags: [], channelToken: token, context: false, fallback: false)) }
        if !mediaID.isEmpty { group.append(.unit(mediaId: mediaID)) }
        return group
    }
    var unitConfigurations : [APEUnitConfiguration] {
        return unitParameters.compactMap {
            APEUnitConfiguration(
                unitParams: $0,
                bundle: Bundle.main,
                hideApesterAds: false,
                gdprString: gdprToken,
                baseUrl: nil,
                environment: environment)
        }
    }
}
///
///
///
extension EnvironmentModel // : CustomDebugStringConvertible
{
    override var description : String
    {
        return """
        Environment: \(environment.description)\n\
        Channel Token: \(token)\n\
        MediaID: \(mediaID)\n\
        GDPR: \(gdprToken ?? "")
        """
    }
    override var debugDescription : String
    {
        return description
    }
}
extension APEEnvironment : CustomStringConvertible {
    public var description: String {
        switch self {
        case .production: return "Production"
        case .stage: return "Staging"
        case .local: return "Local"
        case .dev: return "Development"
        }
    }
}
