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
    fileprivate var displayConstraint: NSLayoutConstraint?
    internal var displayHeight: CGFloat? {
        didSet {
            if let height = displayHeight , displayConstraint?.constant != height {
                setSubviewsVisibility(height != 0.0)
                displayConstraint?.isActive = false
                displayConstraint?.constant = height
                displayConstraint?.isActive = true
            } else {
                displayConstraint?.isActive = false
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
        let constraint = heightAnchor.constraint(equalToConstant: CGFloat(0.0))
        constraint.priority = .defaultHigh
        self.displayConstraint = constraint
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
}
