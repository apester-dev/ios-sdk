//
//  APEContainerViewCompanion.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/6/23.
//
import Foundation
import UIKit
///
///
///
@objc(APEContainerViewCompanion)
@objcMembers
internal class APEContainerViewCompanion : APEContainerView
{    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    internal override func commonInit() {
        applyAutoresizingMask()
        applyBaseConstraint()
    }
}
