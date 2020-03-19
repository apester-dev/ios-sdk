//
//  APEMultipleUnitsViewController.swift
//  Apester
//
//  Created by Hasan Sawaed Tabash on 3/19/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation

import UIKit
import ApesterKit

class APEMultipleUnitsViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
        }
    }

    private var unitsParams: [APEUnitParams] = UnitConfigurationsFactory.unitsParams

    override func viewDidLoad() {
        super.viewDidLoad()
        // update stripView delegates
        unitsParams.forEach { unitParams in
            APEViewService.shared.unitView(for: unitParams.id)?.delegate = self
        }
    }
}

extension APEMultipleUnitsViewController: UICollectionViewDataSource {
    static let emptyCellsCount = 2

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.unitsParams.count * Self.emptyCellsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseCellIdentifier", for: indexPath) as! APEUnitCollectionViewCell
        if indexPath.row % Self.emptyCellsCount == 0 {
            let unit = self.unitsParams[indexPath.row / Self.emptyCellsCount]
            let stripView = APEViewService.shared.unitView(for: unit.id)
            cell.show(unitView: stripView, containerViewConroller: self)
        }
        return cell
    }
}

extension APEMultipleUnitsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row % Self.emptyCellsCount == 0 {
            let unit = self.unitsParams[indexPath.row / Self.emptyCellsCount]
            let stripView = APEViewService.shared.unitView(for: unit.id)
            return CGSize(width: collectionView.bounds.width, height: stripView?.height ?? 0)
        }
        return CGSize(width: collectionView.bounds.width, height: 220)
    }
}

extension APEMultipleUnitsViewController: APEUnitViewDelegate {
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId: String) {
        DispatchQueue.main.async {
            APEViewService.shared.unloadStripViews(with: [unitId])
            self.collectionView.reloadData()
        }
    }

    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId: String) {

    }

    func unitView(_ unitView: APEUnitView, adsCompletedChannelToken unitId: String) {

    }

    func unitView(_ unitView: APEUnitView, didUpdateHeight height: CGFloat) {
        self.collectionView.reloadData()
    }

}
