//
//  APEContainerViewBottom.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/6/23.
//

import UIKit
import Foundation

@objc(APEContainerViewBottom)
@objcMembers
internal class APEContainerViewBottom : APEContainerView
{    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        applyAutoresizingMask()
        applyBaseConstraint()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyAutoresizingMask()
        applyBaseConstraint()
    }
    
//    internal override func applyBaseConstraint() {
//        self.displayConstraintHeight = ape_constraintSelf(with: equalValue(\.heightAnchor, to: .zero) , priority: .required)
//        self.displayConstraintWidth  = ape_constraintSelf(with: equalValue(\.widthAnchor , to: .zero) , priority: .required)
//    }
}
