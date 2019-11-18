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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func show(stripView: APEStripView?, containerViewConroller: UIViewController) {
        stripView?.display(in: self.containerView, containerViewConroller: containerViewConroller)
    }
}
