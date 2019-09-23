//
//  APEStripViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEStripViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    private let token = "5890a541a9133e0e000e31aa"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewFlowLayout(size: view.bounds.size)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupCollectionViewFlowLayout(size: size)
        collectionView.reloadData()
    }

    private func setupCollectionViewFlowLayout(size: CGSize) {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.estimatedItemSize = CGSize(width: size.width, height: 180)
    }
}

extension APEStripViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as! APEStripCollectionViewCell
        cell.display(channelToken: token, containerViewConroller: self, delegate: self)
        return cell
    }
}

extension APEStripViewController: APEStripViewDelegate {

    func stripView(didUpdateHeight height: CGFloat) {
        self.collectionView.reloadData()
    }

    func stripView(didFinishLoadingChannelToken token: String) {}

    func stripView(didFailLoadingChannelToken token: String) {}
}
