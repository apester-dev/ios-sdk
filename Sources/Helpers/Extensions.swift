//
//  Extensions.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
import WebKit

// MARK:- String
 extension String {
    var dictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }

}

extension WKWebView {
    private static let navigatorUserAgent = "navigator.userAgent"

    func appendAppNameToUserAgent(_ appNamed: String?) {
        var userAgent = ""
        MessageDispatcher().dispatchSync(message: WKWebView.navigatorUserAgent, to: self) { response in
            userAgent = (response as? String) ?? ""
        }
        self.customUserAgent = userAgent.replacingOccurrences(of: "iPhone", with: "IPHONE").replacingOccurrences(of: "IPHONE;", with: "\(appNamed ?? "IPHONE");")
    }
}
