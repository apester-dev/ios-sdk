//
//  APEGADBannerView.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import Foundation
import GoogleMobileAds

class APEGADBannerView: UIView {
    var bannerView: GADBannerView?
    var containerView: UIView?
    var containerViewConstraints: [NSLayoutConstraint] = []
    var delegate: APEUnitView.GADViewDelegate?
    var isCompanionVariant: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        params: APEUnitView.GADParams,
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) {
        super.init(frame: .zero)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let delegate = self.delegate ?? self.makeGADViewDelegate(
            containerViewController: containerViewController,
            receiveAdSuccessCompletion: receiveAdSuccessCompletion,
            receiveAdErrorCompletion:  receiveAdErrorCompletion
        )
        let gADView = GADBannerView(adSize: GADAdSizeBanner)
        gADView.translatesAutoresizingMaskIntoConstraints = false
        gADView.delegate = delegate
        gADView.adUnitID = params.adUnitId
        gADView.load(GADRequest())
        self.bannerView = gADView
        self.isCompanionVariant = params.isCompanionVariant
    }
    
    func show(in containerView: UIView) {
        guard let gADView = bannerView,
                superview == nil,
              let containerViewController = self.delegate?.containerViewController
        else {
            return
        }
        self.bannerView?.isHidden = true
        containerView.addSubview(self)
        self.containerView = containerView
        
        gADView.rootViewController = containerViewController
        gADView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            gADViewLayoutConstraints(gADView,
                                     containerView: containerView,
                                     isCompanionVariant: isCompanionVariant)
        )
    }
    
    @objc func hide() {
        removeFromSuperview()
    }
    
    func refresh() {}
}

private extension APEGADBannerView {
    
    func makeGADViewDelegate(
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.GADViewDelegate {
        .init(containerViewController: containerViewController,
                        receiveAdSuccessCompletion: {
            if let containerView = self.containerView {
                self.removeConstraints(self.containerViewConstraints)
                self.containerViewConstraints = [
                    self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    self.topAnchor.constraint(equalTo: containerView.topAnchor),
                    self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ]
                self.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(self.containerViewConstraints)
            }
            self.bannerView?.isHidden = false
            receiveAdSuccessCompletion()
                        },
                        receiveAdErrorCompletion: { error in
            receiveAdErrorCompletion(error)
            print(error?.localizedDescription ?? "")
                        })
    }
    
    private func gADViewLayoutConstraints(_ gADView: GADBannerView,
                                          containerView: UIView,
                                          isCompanionVariant: Bool) -> [NSLayoutConstraint] {
        var constraints = [
            gADView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gADView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        if isCompanionVariant {
            constraints.append(gADView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0))
        } else {
            constraints.append(gADView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0))
        }
        return constraints
    }
}
