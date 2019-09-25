//
//  APEStripServiceEventsTracker.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

// MARK:- APEStripServiceEventsTracker
class APEStripServiceEventsTracker {

    private var messages: [Int: String] = [:]

    func canSendApesterEvent(message: String, to webView: WKWebView) -> Bool {
        return self.messages[webView.hash] != message
    }

    func evaluateJavaScript(message: String, to webView: WKWebView, completion: ((Any?) -> Void)? = nil) {
        webView.evaluateJavaScript(message) { (response, error) in
            completion?(response)
        }
    }

    func sendApesterEvent(message: String, to webView: WKWebView, completion: ((Any?) -> Void)? = nil) {
        self.messages[webView.hash] = message
        self.evaluateJavaScript(message: APEConfig.Strip.sendApesterEvent(with: message), to: webView, completion: completion)
    }

}
