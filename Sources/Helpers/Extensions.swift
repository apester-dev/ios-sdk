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
        let events: [String]
        let contentBehavior: UIScrollView.ContentInsetAdjustmentBehavior
        weak var delegate: Delegate?
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

    static func make(with options: Options) -> WKWebView {
        let delegate = options.delegate
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
        webView.scrollView.delegate = delegate
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

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, paddingTop: CGFloat, bottom: NSLayoutYAxisAnchor?, paddingBottom: CGFloat, leadingAnchor: NSLayoutXAxisAnchor?, paddingLeading: CGFloat, trailingAnchor: NSLayoutXAxisAnchor?, paddingTrailing: CGFloat, width: CGFloat?, height: CGFloat?)
    {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom ).isActive = true
        }
        if let trailingAnchor = trailingAnchor {
            self.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingTrailing ).isActive = true
        }
        if let leadingAnchor = leadingAnchor {
            self.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeading).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
