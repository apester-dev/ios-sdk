//
//  Extensions.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import CoreGraphics
import Foundation

// MARK:- Dictionary Extension
extension Dictionary {

    func componentsURL(baseURL urlString: String) -> URL? {
        var components = URLComponents(string: urlString)
        components?.queryItems = self.compactMap { (arg) in
            guard let key = arg.key as? String, let value = arg.value as? String else {
                return nil
            }
            return URLQueryItem(name: key, value: value)
        }
        return components?.url
    }

    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
}

// MARK:- String
 extension String {
    var dictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

// MARK:- CGFloat
extension CGFloat {
    init?(string: String) {
        guard let number = NumberFormatter().number(from: string) else {
            return nil
        }
        self.init(number.floatValue)
    }
}
