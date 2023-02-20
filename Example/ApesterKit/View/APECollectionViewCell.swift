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

    func show(stripView: APEStripView?, containerViewController: UIViewController) {
        self.stripView = stripView
        stripView?.display(in: self.containerView, containerViewController: containerViewController)
    }
}

class APEUnitCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var containerView: UIView!
    internal var unitView: APEUnitView?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        unitView = nil
    }

    func show(unitView: APEUnitView?, containerViewController: UIViewController) {
        self.unitView = unitView
        unitView?.display(in: self.containerView, containerViewController: containerViewController)
    }
}
