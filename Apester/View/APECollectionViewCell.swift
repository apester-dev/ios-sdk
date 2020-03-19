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
    private var stripView: APEStripView?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        stripView = nil
    }

    func show(stripView: APEStripView?, containerViewConroller: UIViewController) {
        self.stripView = stripView
        stripView?.display(in: self.containerView, containerViewConroller: containerViewConroller)
    }
}

class APEUnitCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var containerView: UIView!
    private var unitView: APEUnitView?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        unitView = nil
    }

    func show(unitView: APEUnitView?, containerViewConroller: UIViewController) {
        self.unitView = unitView
        unitView?.display(in: self.containerView, containerViewConroller: containerViewConroller)
    }
}
