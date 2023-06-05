//
//  Extensions.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
import UIKit
import WebKit
import OSLog
///
///
///
internal extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Logs Apster content
    static let ApesterSDK = OSLog(subsystem: subsystem, category: "Apster")
}
///
///
///
internal extension Optional
{
    ///
    ///
    ///
    var ape_isExist: Bool {
        guard case .some = self else { return false }
        return true
    }
}
///
///
///
internal extension String {
    
    var ape_dictionary: [String: Any]? {
        
        if let data = self.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
///
///
///
internal extension Dictionary {
    
    func ape_floatValue(for key: Key) -> CGFloat {
        CGFloat(self[key] as? Double ?? 0)
    }
}
///
///
///
internal extension WKWebView {

    struct Options {
        typealias Delegate = WKNavigationDelegate & UIScrollViewDelegate & WKScriptMessageHandler & WKUIDelegate
        let events: [String]
        let contentBehavior: UIScrollView.ContentInsetAdjustmentBehavior
        weak var delegate: Delegate?
    }

    private static let navigatorUserAgent = "navigator.userAgent"

    static func make(with options: Options, params: [String: String]?) -> WKWebView {
        let delegate = options.delegate
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController.register(to: options.events, delegate: delegate)
        if let rawParams = params {
            configuration.userContentController.addScript(params: rawParams);
        }
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: CGRect.init(x: 0.0, y: 0.0, width: 1, height: 1), configuration: configuration)
        webView.navigationDelegate = delegate
        webView.insetsLayoutMarginsFromSafeArea = true
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.delegate = delegate
        webView.uiDelegate = delegate
        webView.scrollView.contentInsetAdjustmentBehavior = options.contentBehavior
        webView.accessibilityIdentifier = "apesterWebContainer"
//        if #available(iOS 15.5, *) {
//            webView.setMinimumViewportInset(UIEdgeInsets.zero, maximumViewportInset: UIEdgeInsets.zero)
//        }
        return webView
    }
}
///
///
///
internal extension UIColor {
    
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

internal extension UIView {
    
    var ape_allSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.ape_allSubviews }
    }
}

internal extension UIApplication
{
    var ape_keyWindow : UIWindow?
    {
        if #available(iOS 13.0, *)
        {
            guard let windowScene = openSessions.first?.scene as? UIWindowScene else { return keyWindow }
            guard let  sceneDelegate = windowScene.delegate                     else { return keyWindow }
            guard let windowDelegate = sceneDelegate as? UIWindowSceneDelegate  else { return keyWindow }
            return windowDelegate.window ?? keyWindow
        }
        else
        {
            return keyWindow
        }
    }
}
// Convenience tuple to handle constraint application
internal typealias APEConstraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

// Convenience functions to enable simple code based constraints, works with the view anchor keypaths
// ================================================================================================================== //

// These methods return an inactive constraint of the form thisAnchor = otherAnchor + constant.
internal func          equal<L, Axis>(_ to: KeyPath<UIView, L>, constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutAnchor<Axis> {
    return equal(to, to, constant: c)
}
internal func greaterOrEqual<L, Axis>(_ to: KeyPath<UIView, L>, constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutAnchor<Axis> {
    return greaterOrEqual(to, to, constant: c)
}
internal func    lessOrEqual<L, Axis>(_ to: KeyPath<UIView, L>, constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutAnchor<Axis> {
    return lessOrEqual(to, to, constant: c)
}

// These methods return an inactive constraint of the form thisAnchor = otherAnchor + constant.
internal func          equal<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in view[keyPath: from].constraint(equalTo: parent[keyPath: to], constant: c) }
}
internal func greaterOrEqual<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in view[keyPath: from].constraint(greaterThanOrEqualTo: parent[keyPath: to], constant: c) }
}
internal func    lessOrEqual<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in view[keyPath: from].constraint(lessThanOrEqualTo: parent[keyPath: to], constant: c) }
}

// ================================================================================================================== //

// These methods return an inactive constraint of the form thisVariable = constant.
internal func          equalValue<L>(_ from: KeyPath<UIView, L>, to constant: CGFloat) -> APEConstraint where L: NSLayoutDimension {
    return { view, parent in view[keyPath: from].constraint(             equalToConstant: constant) }
}
internal func greaterOrEqualValue<L>(_ from: KeyPath<UIView, L>, to constant: CGFloat) -> APEConstraint where L: NSLayoutDimension {
    return { view, parent in view[keyPath: from].constraint(greaterThanOrEqualToConstant: constant) }
}
internal func    lessOrEqualValue<L>(_ from: KeyPath<UIView, L>, to constant: CGFloat) -> APEConstraint where L: NSLayoutDimension {
    return { view, parent in view[keyPath: from].constraint(   lessThanOrEqualToConstant: constant) }
}

// These methods return an inactive constraint of the form thisAnchor = otherAnchor * multiplier + constant.
internal func          equalValue<L>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, multiplier m: CGFloat = CGFloat(1.0), constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutDimension {
    return { view, parent in view[keyPath: from].constraint(             equalTo: parent[keyPath: to], multiplier: m, constant: c) }
}
internal func greaterOrEqualValue<L>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, multiplier m: CGFloat = CGFloat(1.0), constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutDimension {
    return { view, parent in view[keyPath: from].constraint(greaterThanOrEqualTo: parent[keyPath: to], multiplier: m, constant: c) }
}
internal func    lessOrEqualValue<L>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, multiplier m: CGFloat = CGFloat(1.0), constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutDimension {
    return { view, parent in view[keyPath: from].constraint(   lessThanOrEqualTo: parent[keyPath: to], multiplier: m, constant: c) }
}
// ================================================================================================================== //
// These methods return an inactive constraint of the form thisAnchor = otherAnchor * multiplier + constant.
internal func          equalValue<L>(to: KeyPath<UIView, L>, multiplier m: CGFloat = CGFloat(1.0), constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutDimension {
    return          equalValue(to, to, multiplier: m, constant: c)
}
internal func greaterOrEqualValue<L>(to: KeyPath<UIView, L>, multiplier m: CGFloat = CGFloat(1.0), constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutDimension {
    return greaterOrEqualValue(to, to, multiplier: m, constant: c)
}
internal func    lessOrEqualValue<L>(to: KeyPath<UIView, L>, multiplier m: CGFloat = CGFloat(1.0), constant c: CGFloat = .zero) -> APEConstraint where L: NSLayoutDimension {
    return    lessOrEqualValue(to, to, multiplier: m, constant: c)
}
// ================================================================================================================== //
// MARK: - constraints handling
internal extension UIView {
    
    static var anchorToContainer : [APEConstraint]
    {
        return [
            equal(\.topAnchor)   , equal(\.leadingAnchor),
            equal(\.bottomAnchor), equal(\.trailingAnchor)
        ]
    }
    
    @discardableResult
    func ape_addSubview(
        _ other: UIView,
        with constraints: [APEConstraint] ,
        priority : UILayoutPriority = .required
    ) -> [NSLayoutConstraint] {
        addSubview(other)
        return ape_anchor(view: other, with: constraints, priority: priority)
    }
    
    @discardableResult
    func ape_anchor(
        view other: UIView,
        with constraints: [APEConstraint],
        priority : UILayoutPriority = .required
    ) -> [NSLayoutConstraint] {
        let c = ape_constraints(view: other, with: constraints, priority: priority)
        NSLayoutConstraint.activate(c)
        return c
    }
    
    @discardableResult
    func ape_constraints(
        view other: UIView,
        with constraints: [APEConstraint],
        priority : UILayoutPriority = .defaultHigh
    ) -> [NSLayoutConstraint] {
        
        return constraints.compactMap {
            ape_constraint(view: other, with: $0, priority: priority)
        }
    }
    
    
    
    @discardableResult
    func ape_constraint(
        view other: UIView,
        with constraint: APEConstraint,
        priority : UILayoutPriority = .defaultHigh
    ) -> NSLayoutConstraint {
        
        other.translatesAutoresizingMaskIntoConstraints = false
        
        let c = constraint(other, self)
        c.priority = priority
        return c
    }
   
    
    @discardableResult
    func ape_anchor(
        view other: UIView,
        with constraint: APEConstraint,
        priority : UILayoutPriority = .defaultHigh
    ) -> NSLayoutConstraint {
        let c = ape_constraint(view: other, with: constraint, priority: priority)
        NSLayoutConstraint.activate([c])
        return c
    }
    
    @discardableResult
    func ape_constraintSelf(
        with constraint: APEConstraint,
        priority : UILayoutPriority = .defaultHigh
    ) -> NSLayoutConstraint {
        return ape_constraint(view: self, with: constraint, priority: priority)
    }
    @discardableResult
    func ape_anchorSelf(
        with constraint: APEConstraint,
        priority : UILayoutPriority = .defaultHigh
    ) -> NSLayoutConstraint {
        let c = ape_constraintSelf(with: constraint, priority: priority)
        NSLayoutConstraint.activate([c])
        return c
    }
}
