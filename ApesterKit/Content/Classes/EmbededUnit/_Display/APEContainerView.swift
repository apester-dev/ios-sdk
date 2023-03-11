//
//  APEContainerView.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/6/23.
//

import WebKit
import Foundation

@objc(APEContainerView)
@objcMembers
public class APEContainerView : UIView
{
    var isEmpty    : Bool { subviews.isEmpty }
    var hasContent : Bool { !isEmpty }
    
    // MARK: - constraints
    internal var displayConstraintHeight: NSLayoutConstraint?
    internal var displayHeight: CGFloat? {
        didSet {
            if let value = displayHeight {
                update(constraint: displayConstraintHeight, by: value, visibility: true)
            } else {
                displayConstraintHeight?.isActive = false
            }
        }
    }
    internal var displayConstraintWidth: NSLayoutConstraint?
    internal var displayWidth: CGFloat? {
        didSet {
            if let value = displayWidth {
                update(constraint: displayConstraintWidth, by: value, visibility: false)
            } else {
                displayConstraintWidth?.isActive = false
            }
        }
    }
    
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
    
    internal func applyAutoresizingMask() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    internal func applyBaseConstraint() {
        self.displayConstraintHeight = ape_constraintSelf(with: equalValue(\.heightAnchor, to: .zero) , priority: .required)
        self.displayConstraintWidth  = ape_constraintSelf(with: equalValue(\.widthAnchor , to: .zero) , priority: .required)
    }

    // MARK: - touch event handling
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    // MARK: -
    internal func setSubviewsVisibility(_ visibility: Bool) {
        subviews.forEach { $0.isHidden = !visibility }
    }
    
    // MARK: -
    private func update(
        constraint item: NSLayoutConstraint?,
        by value: CGFloat, visibility: Bool
    ) {
        guard item?.constant != value else { return }
        if (visibility) { setSubviewsVisibility(value != 0.0) }
        item?.isActive = false
        item?.constant = value
        item?.isActive = true
    }
    
}
