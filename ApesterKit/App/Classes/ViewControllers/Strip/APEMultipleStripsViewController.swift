//
//  APEMultipleStripsViewController.swift
//  Apister
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import ApesterKit

class APEMultipleStripsViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
        }
    }

    private var channelTokens: [String] = StripConfigurationsFactory.tokens

    override func viewDidLoad() {
        super.viewDidLoad()
        // update stripView delegates
        channelTokens.forEach {
            APEViewService.shared.stripView(for: $0)?.delegate = self
        }
    }
}

extension APEMultipleStripsViewController: UICollectionViewDataSource {
    static let emptyCellsCount = 2

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.channelTokens.count * Self.emptyCellsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseCellIdentifier", for: indexPath) as! APEStripCollectionViewCell
        if indexPath.row % Self.emptyCellsCount == 0 {
            let token = self.channelTokens[indexPath.row / Self.emptyCellsCount]
            let stripView = APEViewService.shared.stripView(for: token)
            cell.show(stripView: stripView, containerViewController: self)
        }
        return cell
    }
}

extension APEMultipleStripsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row % Self.emptyCellsCount == 0 {
            let token = self.channelTokens[indexPath.row / Self.emptyCellsCount]
            let stripView = APEViewService.shared.stripView(for: token)
            return CGSize(width: collectionView.bounds.width, height: stripView?.height ?? 0)
        }
        return CGSize(width: collectionView.bounds.width, height: 220)
    }
}

extension APEMultipleStripsViewController: APEStripViewDelegate {
    
    func stripView(_ stripView: APEStripView, didCompleteAdsForChannelToken token: String) {
    }
    

    func stripView(_ stripView: APEStripView, didUpdateHeight height: CGFloat) {
        self.collectionView.reloadData()
    }

    func stripView(_ stripView: APEStripView, didFinishLoadingChannelToken token: String) {}

    func stripView(_ stripView: APEStripView, didFailLoadingChannelToken token: String) {
        DispatchQueue.main.async {
            APEViewService.shared.unloadStripViews(with: [token])
            self.collectionView.reloadData()
        }
    }
}
