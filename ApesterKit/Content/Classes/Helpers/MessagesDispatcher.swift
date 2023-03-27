//
//  MessageDispatcher.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
import WebKit
///
///
///
// MARK:- MessageDispatcher
internal class MessageDispatcher
{
    // MARK: - typealias
    internal typealias HandlerAnyOptionalType = (Any?) -> Void
    // MARK: - Properties
    private var messages            : [Int:String]       = [:]
    private var synchronizationLock : SynchronizedScript = SynchronizedScript()
    
    private func dispatch(message: String, to webView: WKWebView, completion: HandlerAnyOptionalType? = nil)
    {
        webView.evaluateJavaScript(message) { (response, error) in
            completion?(response)
        }
    }

    func contains(message: String, for webView: WKWebView) -> Bool
    {
        return self.messages[webView.hash] == message
    }

    func dispatch(apesterEvent message: String, to webView: WKWebView, completion: HandlerAnyOptionalType? = nil)
    {
        self.messages[webView.hash] = message
        self.dispatch(message: Constants.WebView.sendApesterEvent(with: message), to: webView, completion: completion)
    }

    func dispatchAsync(_ message: String, to webView: WKWebView, completion: HandlerAnyOptionalType? = nil)
    {
        self.messages[webView.hash] = message
        self.dispatch(message: message, to: webView, completion: completion)
    }

    func dispatchSync(message: String, to webView: WKWebView, completion: HandlerAnyOptionalType? = nil)
    {
        let script = synchronizationLock // SynchronizedScript()
        script.lock()
        self.dispatch(message: message, to: webView) { response in
            completion?(response)
            script.unlock()
        }
        script.wait()
    }
    
    func sendNativeAdEvent(
        to webView: WKWebView,
        named event: String,
        adType: String,
        ofType monetizationType: String,
        provider monetizationProvider: String,
        inActive display: Bool
    ) {
        self.dispatch(apesterEvent: "{ type: \"native_ad_report\", nativeAdEvent: \"\(event)\", nativeAdType: \"\(adType)\", monType: \"\(monetizationType)\", monProvider: \"\(monetizationProvider)\", inView: \"\(display)\" }" , to: webView);
    }
    
    func sendNativeGDPREvent(to webView: WKWebView, consent gdprString: String) {
        self.dispatch(apesterEvent: "{ type: \"gdpr_success\", consent: \"\(gdprString)\" }", to: webView);
    }
}
