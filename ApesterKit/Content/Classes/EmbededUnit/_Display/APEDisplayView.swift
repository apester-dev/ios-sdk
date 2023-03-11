//
//  APEDisplayView.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 2/9/23.
//  Copyright © 2023 Apester. All rights reserved.
//

import UIKit
import Foundation

@objc(APEDisplayView)
@objcMembers
public class APEDisplayView : APEContainerView
{    
    // MARK: - sub views
    internal var adUnit     : APEContainerViewUnit!
    internal var adBottom   : APEContainerViewBottom!
    internal var adCompanion: APEContainerViewCompanion!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.apply_autoresizingMask()
        self.apply_baseConstraint()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubviews()
        self.apply_autoresizingMask()
        self.apply_baseConstraint()
    }
    fileprivate func addSubviews() {
        adUnit      = APEContainerViewUnit     (frame: .zero)
        adBottom    = APEContainerViewBottom   (frame: .zero)
        adCompanion = APEContainerViewCompanion(frame: .zero)
    }
    fileprivate func apply_autoresizingMask() {
        self.adUnit     .translatesAutoresizingMaskIntoConstraints = false
        self.adBottom   .translatesAutoresizingMaskIntoConstraints = false
        self.adCompanion.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func apply_baseConstraint() {
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
        ], priority: .required)
        constraints += adUnit.ape_constraints(view: adBottom , with: [
            equal(\.topAnchor, \.bottomAnchor, constant: 0)
        ], priority: .required)
        constraints += ape_constraints(view: adBottom, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ], priority: .required)
        constraints += adCompanion.ape_constraints(view: adBottom , with: [
            equal(\.bottomAnchor, \.topAnchor, constant: 0)
        ], priority: .required)
        constraints += ape_constraints(view: adCompanion, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ], priority: .required)

        NSLayoutConstraint.activate(constraints)
    }
    fileprivate func applyDebug() {
        return;
        // adUnit      .backgroundColor = .red
        // adBottom    .backgroundColor = .magenta
        // adCompanion .backgroundColor = .cyan
        // backgroundColor = .purple
    }
    
    // MARK: -
    @discardableResult
    internal func applyLayoutHeight(
        _ heightInUnitContent: CGFloat,
        _ heightInUnitBanner: CGFloat,
        _ heightBottom: CGFloat,
        _ heightCompanion: CGFloat
    ) -> CGFloat {
        displayHeight = heightInUnitContent + heightBottom + heightCompanion
        adUnit.applyLayoutHeight(heightInUnitContent, heightInUnitBanner)
        adBottom   .displayHeight = heightBottom
        adCompanion.displayHeight = heightCompanion
        return displayHeight ?? CGFloat(0.0)
    }
    internal func removeBannerViews() {
        adUnit.removeBannerViews()
        adBottom.subviews.forEach { $0.removeFromSuperview() }
        adCompanion.subviews.forEach { $0.removeFromSuperview() }
    }
}
