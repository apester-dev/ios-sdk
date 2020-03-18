//
//  StripConfigurationsFactory.swift
//  Apester
//
//  Created by Hasan Sawaed Tabash on 3/1/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit
import ApesterKit

@objcMembers class StripConfigurationsFactory: NSObject {
    private static let style: APEStripStyle = {
        APEStripStyle(shape: .roundSquare,
                      size: .medium,
                      padding: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 0, right: 0),
                      shadow: false,
                      textColor: nil,
                      background: .white,
                      header: APEStripHeader(text: "Weitere Beiträge", size: 25.0, family: "Knockout", weight:400, color: .black))
    }()

    static private(set) var tokens: [String] = []

    static func configurations(for env: APEEnvironment = .production, noApesterAds: Bool) -> [APEStripConfiguration]  {
        var tokens: [String]
        switch env {
            case .production:
            tokens = ["5e03500a2fd560e0220ff327", "5ad092c7e16efe4e5c4fb821", "58ce70315eeaf50e00de3da7", "5aa15c4f85b36c0001b1023c"]
            case .stage:
            tokens = ["58c551f76a67357e3b4aa943"]
        case .local:
            tokens = ["5d6fc15d07d512002b67ecc6"]
        }
        self.tokens = tokens
        return makeStripConfigurations(with: tokens, environment: env, noApesterAds: noApesterAds)
    }

    /// transform all given channel toekns to [APEStripConfiguration]
    /// - Parameter channleTokens: the channelTokens to transform
    static func makeStripConfigurations(with channleTokens: [String], environment: APEEnvironment, noApesterAds: Bool) -> [APEStripConfiguration] {
        channleTokens.compactMap {
            try? APEStripConfiguration(channelToken: $0, style: style, bundle: Bundle.main, environment: environment, noApesterAds: noApesterAds)
        }
    }
}
