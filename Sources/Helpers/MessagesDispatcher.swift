//
//  MessageDispatcher.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

// MARK:- MessageDispatcher
class MessageDispatcher {

    private var messages: [Int: String] = [:]


    private func dispatch(message: String, to webView: WKWebView, completion: ((Any?) -> Void)? = nil) {
        webView.evaluateJavaScript(message) { (response, error) in
            completion?(response)
        }
    }

    func contains(message: String, for webView: WKWebView) -> Bool {
        return self.messages[webView.hash] == message
    }

    func dispatch(apesterEvent message: String, to webView: WKWebView, completion: ((Any?) -> Void)? = nil) {
        self.messages[webView.hash] = message
        self.dispatch(message: Constants.Strip.sendApesterEvent(with: message), to: webView, completion: completion)
    }

    func dispatchSync(message: String, to webView: WKWebView, completion: ((Any?) -> Void)? = nil) {
        let script = SynchronizedScript()
        script.lock()
        self.dispatch(message: message, to: webView) { response in
            completion?(response)
            script.unlock()
        }
        script.wait()
    }

}
