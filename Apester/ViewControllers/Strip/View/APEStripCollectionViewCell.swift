//
//  APEStripCollectionViewCell.swift
//  Apester
//
//  Created by Hasan Sawaed Tabash on 9/23/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import ApesterKit

class APEStripCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var containerView: UIView!

    private lazy var style: APEStripStyle = {
        return APEStripStyle(shape: .roundSquare, size: .medium,
                             padding: UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0),
                             shadow: false, textColor: nil, background: nil)
    }()

    private lazy var stripView: APEStripView? = {
        // set strip params
        if let configuration = try? APEStripConfiguration(channelToken: self.channelToken,
                                                          style: style,
                                                          bundle: Bundle.main) {
            // create the StripService Instance
            return APEStripView(configuration: configuration)
        }
        return nil
    }()

    private var channelToken: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        frame.origin = .zero
        frame.size.height = stripView?.height ?? frame.size.height
        layoutAttributes.frame = frame
        return layoutAttributes
    }

    func display(channelToken: String, containerViewConroller: UIViewController, delegate: APEStripViewDelegate?) {
        self.channelToken = channelToken
        stripView?.delegate = delegate
        stripView?.display(in: self.containerView, containerViewConroller: containerViewConroller)
    }
}
