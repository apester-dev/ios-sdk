//
//  FeedApesterCell.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/7/22.
//
import UIKit
import ApesterKit
///
///
///
class FeedApesterCell : UICollectionViewCell , Nibable , Reusable
{
    // MARK: - Properties
    internal var displayedUnitView: APEUnitView?
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - overrides
    override func awakeFromNib()
    {
        super.awakeFromNib()
        containerView.backgroundColor = .red
    }
    
    override func prepareForReuse()
    {
        displayedUnitView = nil
        containerView.backgroundColor = .red
    }
    
    // MARK: - Public API
    func show(unitView: APEUnitView?, containerViewController: UIViewController) {
        displayedUnitView = unitView
        unitView?.display(in: self.containerView, containerViewController: containerViewController)
    }
    
//    // MARK: - Override
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        
//        setNeedsLayout()
//        layoutIfNeeded()
//        
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        layoutAttributes.frame = frame
//        
//        return layoutAttributes
//    }
    
    override var accessibilityIdentifier: String? {
        get { String(describing: type(of: self)) }
        set {}
    }
}
