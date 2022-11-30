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
    
    private let configurations = UnitConfigurationsFactory.configurations(hideApesterAds: false)
    
    private lazy var unitsParams: [APEUnitParams] = { configurations.map(\.unitParams) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let l = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            l.estimatedItemSize = collectionView.bounds.size
        }
        
        // update unitViews delegates
        unitsParams.forEach { unitParams in
            if APEViewService.shared.unitView(for: unitParams.id) == nil {
                // not preload!
                APEViewService.shared.preloadUnitViews(with: UnitConfigurationsFactory.configurations(hideApesterAds: false))
            }
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
            cell.show(unitView: stripView, containerViewController: self)
        }
        return cell
    }
}

extension APEMultipleUnitsViewController: APEUnitViewDelegate {
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId: String) {
        DispatchQueue.main.async {
            APEViewService.shared.unloadUnitViews(with: [unitId])
            self.collectionView.reloadData()
        }
    }
    
    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId: String) {
        
    }
    
    func unitView(_ unitView: APEUnitView, didCompleteAdsForUnit unitId: String) {
        print(unitId)
    }
    
    func unitView(_ unitView: APEUnitView, didUpdateHeight height: CGFloat) {
        print("## unitView.didUpdateHeight: \(height), \(unitView.height), \(unitView.configuration.unitParams.id)")
        collectionView.reloadData()
    }
}
