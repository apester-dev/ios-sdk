//
//  APEDisplayView.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 2/9/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import WebKit
import UIKit
import Foundation

@objcMembers
public class APEContainerView : UIView
{
    var isEmpty     : Bool { subviews.isEmpty }
    var hasContent  : Bool { !isEmpty }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    // MARK: -
    fileprivate func setSubviewsVisibility(_ visibility: Bool) {
        subviews.forEach { $0.isHidden = !visibility }
    }
}

@objcMembers
internal class APEContainerViewUnit : APEContainerView {
    
    // MARK: - constraints
    fileprivate var displayConstraint: NSLayoutConstraint?
    internal fileprivate(set) var displayHeight: CGFloat? {
        didSet {
            if let height = displayHeight , displayConstraint?.constant != height {
                setNeedsUpdateConstraints()
                setNeedsLayout()
                setSubviewsVisibility(height != 0.0)
                displayConstraint?.isActive = false
                displayConstraint?.constant = height
                displayConstraint?.isActive = true
                layoutIfNeeded()
            } else {
                displayConstraint?.isActive = false
            }
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyBaseConstraint()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyBaseConstraint()
    }
    fileprivate func applyAutoresizingMask() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.webContent     .translatesAutoresizingMaskIntoConstraints = false
        self.adContentMain  .translatesAutoresizingMaskIntoConstraints = false
        self.adContentBunner.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func applyBaseConstraint() {
        self.displayConstraint = heightAnchor.constraint(equalToConstant: CGFloat(0.0))
        self.displayConstraint?.priority = .required
    }
    
    // MARK: -
    // MARK: -
    internal var webContent : WKWebView! {
        didSet {
            adContentMain   = APEContainerView(frame: .zero)
            adContentBunner = APEContainerView(frame: .zero)
            applyAutoresizingMask()
            applyLayout()
            applyDebug()
        }
    }
    internal fileprivate(set) var adContentMain   : APEContainerView!
    internal fileprivate(set) var adContentBunner : APEContainerView!
    
    fileprivate func applyLayout() {
        
        // webview
        ape_addSubview(webContent, with: UIView.anchorToContainer)
        
        // cpm
        ape_addSubview(adContentMain, with: UIView.anchorToContainer)
        
        // bottom - bunner - inside
        addSubview(adContentBunner)
        webContent.ape_anchor(view: adContentBunner, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        adBottomConstraint = adContentBunner.heightAnchor.constraint(equalToConstant: 0)
        adBottomConstraint?.priority = .init(rawValue: 999)
        // adBottomConstraint = adContentBunner.heightAnchor.constraint(equalToConstant: APEUnitView.Monetization.AdType.bottom.height)
    }
    fileprivate func applyDebug() {
        return;
        // webContent      .backgroundColor = .red
        // adContentMain   .backgroundColor = .green.withAlphaComponent(CGFloat(0.3))
        // adContentBunner .backgroundColor = .brown
    }
    
    // MARK: -
    @discardableResult
    internal func applyPreviewHeight(
        _ heightInUnitContent: CGFloat
    ) -> CGFloat {
        return applyLayoutHeight(heightInUnitContent, CGFloat(0.0))
    }
    @discardableResult
    internal func applyLayoutHeight(
        _ heightInUnitContent: CGFloat,
        _ heightInUnitBanner: CGFloat
    ) -> CGFloat {
        adBottomHeight   = heightInUnitBanner
        displayHeight    = heightInUnitContent
        return displayHeight ?? CGFloat(0.0)
    }
    internal func removeBannerViews() {
        adContentMain  .subviews.forEach { $0.removeFromSuperview() }
        adContentBunner.subviews.forEach { $0.removeFromSuperview() }
    }
    internal func removeInUnitAd() {
        adContentMain.subviews.forEach { $0.removeFromSuperview() }
    }
    // MARK: - =========================================================================================================
    private var adBottomConstraint: NSLayoutConstraint?
    private var adBottomHeight: CGFloat? {
        didSet {
            guard let height = adBottomHeight else { return }
            adBottomConstraint?.isActive = false
            adBottomConstraint?.constant = height
            adBottomConstraint?.isActive = true
        }
    }
}

@objcMembers
internal class APEContainerViewBottom : APEContainerView {
    
    // MARK: - constraints
    fileprivate var displayConstraint: NSLayoutConstraint?
    fileprivate var displayHeight: CGFloat? {
        didSet {
            if let height = displayHeight {
                setNeedsUpdateConstraints()
                setNeedsLayout()
                setSubviewsVisibility(height != 0.0)
                displayConstraint?.isActive = false
                displayConstraint?.constant = height
                displayConstraint?.isActive = true
                layoutIfNeeded()
            } else {
                displayConstraint?.isActive = false
            }
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyAutoresizingMask()
        applyLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyAutoresizingMask()
        applyLayout()
    }
    fileprivate func applyAutoresizingMask() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func applyLayout() {
        displayConstraint = heightAnchor.constraint(equalToConstant: CGFloat(0.0))
    }
}

@objcMembers
internal class APEContainerViewCompanion : APEContainerView {
    
    // MARK: - constraints
    fileprivate var displayConstraint: NSLayoutConstraint?
    fileprivate var displayHeight: CGFloat? {
        didSet {
            if let height = displayHeight {
                setNeedsUpdateConstraints()
                setNeedsLayout()
                setSubviewsVisibility(height != 0.0)
                displayConstraint?.isActive = false
                displayConstraint?.constant = height
                displayConstraint?.isActive = true
                layoutIfNeeded()
            } else {
                displayConstraint?.isActive = false
            }
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyAutoresizingMask()
        applyLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyAutoresizingMask()
        applyLayout()
    }
    fileprivate func applyAutoresizingMask() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func applyLayout() {
        displayConstraint = heightAnchor.constraint(equalToConstant: CGFloat(0.0))
        displayConstraint?.priority = .required
    }
}

@objcMembers
public class APEDisplayView : APEContainerView {
    
    // MARK: - sub views
    internal var adUnit     : APEContainerViewUnit!
    internal var adBottom   : APEContainerViewBottom!
    internal var adCompanion: APEContainerViewCompanion!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.applyAutoresizingMask()
        self.applyBaseConstraint()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubviews()
        self.applyAutoresizingMask()
        self.applyBaseConstraint()
    }
    fileprivate func addSubviews() {
        adUnit      = APEContainerViewUnit     (frame: .zero)
        adBottom    = APEContainerViewBottom   (frame: .zero)
        adCompanion = APEContainerViewCompanion(frame: .zero)
    }
    fileprivate func applyAutoresizingMask() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.adUnit     .translatesAutoresizingMaskIntoConstraints = false
        self.adBottom   .translatesAutoresizingMaskIntoConstraints = false
        self.adCompanion.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func applyBaseConstraint() {
        displayConstraint = heightAnchor.constraint(equalToConstant: CGFloat(0.0))
        applyLayout()
        applyDebug()
    }
    
    // MARK: - constraints
    fileprivate var displayConstraint: NSLayoutConstraint?
    internal    var displayHeight: CGFloat? {
        didSet {
            if let height = displayHeight {
                setNeedsUpdateConstraints()
                setNeedsLayout()
                displayConstraint?.isActive = false
                displayConstraint?.constant = height
                displayConstraint?.isActive = true
                layoutIfNeeded()
            } else {
                displayConstraint?.isActive = false
            }
        }
    }
    
    // MARK: -
    fileprivate func applyLayout() {
        displayConstraint = heightAnchor.constraint(equalToConstant: CGFloat(0.0))
        
        addSubview(adUnit)
        addSubview(adBottom)
        addSubview(adCompanion)
        
        var constraints = [NSLayoutConstraint]()
        constraints += ape_constraints(view: adUnit     , with: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ], priority: .init(rawValue: 999))
        constraints += adUnit.ape_constraints(view: adBottom , with: [
            equal(\.topAnchor, \.bottomAnchor, constant: 0)
        ], priority: .init(rawValue: 999))
        constraints += ape_constraints(view: adBottom, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ], priority: .init(rawValue: 999))
        constraints += adCompanion.ape_constraints(view: adBottom , with: [
            equal(\.bottomAnchor, \.topAnchor, constant: 0)
        ], priority: .init(rawValue: 999))
        constraints += ape_constraints(view: adCompanion, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ], priority: .init(rawValue: 999))
        
        NSLayoutConstraint.activate(constraints)
    }
    fileprivate func applyDebug() {
        return;
        // adUnit      .backgroundColor = .red
        // adBottom    .backgroundColor = .magenta
        // adCompanion .backgroundColor = .cyan
    }
    
    // MARK: -
    @discardableResult
    internal func applyPreviewHeight(
        _ heightInUnitContent: CGFloat
    ) -> CGFloat {
        adUnit.applyPreviewHeight(heightInUnitContent)
        adBottom   .displayHeight = CGFloat(0.0)
        adCompanion.displayHeight = CGFloat(0.0)
        displayHeight = heightInUnitContent
        return displayHeight ?? CGFloat(0.0)
    }
    @discardableResult
    internal func applyLayoutHeight(
        _ heightInUnitContent: CGFloat,
        _ heightInUnitBanner: CGFloat,
        _ heightBottom: CGFloat,
        _ heightCompanion: CGFloat
    ) -> CGFloat {
        adUnit.applyLayoutHeight(heightInUnitContent, heightInUnitBanner)
        adBottom   .displayHeight = heightBottom
        adCompanion.displayHeight = heightCompanion
        displayHeight = heightInUnitContent + heightBottom + heightCompanion
        return displayHeight ?? CGFloat(0.0)
    }
    internal func removeBannerViews() {
        adUnit.removeBannerViews()
        adBottom.subviews.forEach { $0.removeFromSuperview() }
        adCompanion.subviews.forEach { $0.removeFromSuperview() }
    }
    internal func removeInUnitAd() {
        adUnit.removeInUnitAd()
    }
}
