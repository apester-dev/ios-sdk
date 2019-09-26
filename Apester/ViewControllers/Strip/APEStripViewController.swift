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

    private let colors: [UIColor] = [.blue, .red, .green, .purple, .orange, .darkGray ].shuffled()

    private let channelToken = "5890a541a9133e0e000e31aa"
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

    private lazy var style: APEStripStyle = {
        return APEStripStyle(shape: .roundSquare, size: .medium,
                             padding: UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0),
                             shadow: false, textColor: nil, background: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentInsetAdjustmentBehavior = .never
        if let configuration = try? APEStripConfiguration(channelToken: self.channelToken,
                                                          style: style,
                                                          bundle: Bundle.main) {
            // create the StripService Instance
            self.stripView = APEStripView(configuration: configuration)
            stripView?.delegate = self
        }
    }
}

extension APEStripViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        if indexPath.row == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseIdentifier", for: indexPath)
            (cell as! APEStripCollectionViewCell).show(stripView: self.stripView, containerViewConroller: self)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultReuseIdentifier", for: indexPath) 
            cell.contentView.backgroundColor = colors[indexPath.row % colors.count]
        }
        return cell
    }
}

extension APEStripViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let random = CGFloat((180...400).randomElement().flatMap({ $0 }) ?? 180)
        var size = CGSize(width: collectionView.bounds.width, height: random)
        if indexPath.row == 1 {
            size.height = self.stripView?.height ?? 180
        }
        return size
    }
}

extension APEStripViewController: APEStripViewDelegate {

    func stripView(_ stripView: APEStripView, didUpdateHeight height: CGFloat) {
        self.collectionView.reloadData()
    }

    func stripView(_ stripView: APEStripView, didFinishLoadingChannelToken token: String) {}

    func stripView(_ stripView: APEStripView, didFailLoadingChannelToken token: String) {}
}
