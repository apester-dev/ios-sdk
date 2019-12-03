//
//  APEEnvironment.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 11/18/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

@objc public class APEEnvironment: NSObject {

    public enum EnvironmentType {
        case production, stage
        case local(_: String)
    }

    public private(set) var type: EnvironmentType!

    private override init() {
        super.init()
    }

    public init(_ type: EnvironmentType) {
        self.type = type
        super.init()
    }

    var baseUrlString: String {
        switch self.type {
            case .production:
                return "https://faststrip.apester.com"
            case .stage:
                return "https://faststrip.stg.apester.com"
            case .local(let url):
                return url
            case .none: fatalError()
        }
    }
    // MARK: @backward compatibility
    @objc public static private(set) var production = APEEnvironment(.production)
    @objc public static private(set) var stage = APEEnvironment(.stage)
    @objc public static private(set) var local: ((String) -> APEEnvironment) = { APEEnvironment(.local($0)) }
}
