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

    struct Options {
        typealias Delegate = WKNavigationDelegate & UIScrollViewDelegate & WKScriptMessageHandler & WKUIDelegate
         typealias UnitDelegate = WKNavigationDelegate & WKScriptMessageHandler & WKUIDelegate
        let events: [String]
        let contentBehavior: UIScrollView.ContentInsetAdjustmentBehavior
        weak var delegate: Delegate?
        weak var unitDelegate: UnitDelegate?
    }

    private static let navigatorUserAgent = "navigator.userAgent"

    func appendAppNameToUserAgent(_ bundleInfo: [String: String]) {
        var userAgent = ""
        MessageDispatcher().dispatchSync(message: WKWebView.navigatorUserAgent, to: self) { response in
            userAgent = (response as? String) ?? ""
        }
        self.customUserAgent = (userAgent + UserAgent.customized(with: bundleInfo))
            .replacingOccurrences(of: "iPhone", with: "IPHONE")
            .replacingOccurrences(of: "iPad", with: "IPAD")
    }

    static func make(with options: Options) -> WKWebView? {
        guard let delegate = (options.delegate ?? options.unitDelegate) else {
            return nil
        }
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController.register(to: options.events, delegate: delegate)
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = delegate
        webView.insetsLayoutMarginsFromSafeArea = true
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bouncesZoom = false
        if ((delegate as? UIScrollViewDelegate) != nil) {
            webView.scrollView.delegate = (delegate as! UIScrollViewDelegate)
        }
        webView.uiDelegate = delegate
        webView.scrollView.contentInsetAdjustmentBehavior = options.contentBehavior
        return webView
    }
    
}

extension UIColor {
    var rgba: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgba = "rgba(\(Int(r * 255)),\(Int(g * 255)),\(Int(b * 255)),\(Int(a * 255.0)))"
        return rgba
    }
}
