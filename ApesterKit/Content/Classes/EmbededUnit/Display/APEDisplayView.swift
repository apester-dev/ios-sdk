//
//  APEDisplayView.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 2/9/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import UIKit

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
    internal override func applyAutoresizingMask() {
        super.applyAutoresizingMask()
        self.adUnit     .translatesAutoresizingMaskIntoConstraints = false
        self.adBottom   .translatesAutoresizingMaskIntoConstraints = false
        self.adCompanion.translatesAutoresizingMaskIntoConstraints = false
    }
    internal override func applyBaseConstraint() {
        super.applyBaseConstraint()
        applyLayout()
        applyDebug()
    }
    
    // MARK: -
    fileprivate func applyLayout() {
        
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
