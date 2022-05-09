
    //
    //  APEPubMaticBannerView.swift
    //  ApesterKit
    //
    //  Created by Hasan Sawaed Tabash on 06/10/2021.
    //  Copyright © 2021 Apester. All rights reserved.
    //

import Foundation
import UIKit
import OpenWrapSDK

class APEPubMaticBannerView: UIView {
    var containerView: UIView?
    var containerViewConstraints: [NSLayoutConstraint] = []
    var titleLabel: UILabel?
    var inUnitBackgroundColor: UIColor = .clear
    var bannerView: POBBannerView?
    var adType: APEUnitView.PubMaticParams.AdType?
    var pubMaticViewTimer: Timer?
    var delegate: APEUnitView.PubMaticViewDelegate?
    var timeInView: Int?
    var onAdRemovalCompletion: ((APEUnitView.PubMaticParams.AdType) -> Void)?
    
    private var makeTitleLabel: (_ text: String) -> UILabel = { text in
        let label = UILabel()
        label.text = text
        label.backgroundColor = .darkText.withAlphaComponent(0.25)
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .lightText
        return label
    }
    
    lazy var closeButton: UIButton = {
        var button: UIButton!
        button = UIButton(type: .custom)
        button.setTitle("🅧", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        params: APEUnitView.PubMaticParams,
        adTitleLabelText: String,
        inUnitBackgroundColor: UIColor,
        containerViewController: UIViewController,
        onAdRemovalCompletion: @escaping ((APEUnitView.PubMaticParams.AdType) -> Void),
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) {
        super.init(frame: .zero)
        let appInfo = POBApplicationInfo()
        appInfo.domain = params.appDomain
        appInfo.storeURL = URL(string: params.appStoreUrl)!
        OpenWrapSDK.setApplicationInfo(appInfo)
        let adType: APEUnitView.PubMaticParams.AdType = params.adType
        
        let adSizes = [POBAdSizeMake(adType.size.width, adType.size.height)].compactMap({ $0 })
        
        let pubMaticView = POBBannerView(publisherId: params.publisherId,
                                         profileId: .init(value: params.profileId),
                                         adUnitId: params.adUnitId,
                                         adSizes: adSizes)
        
        pubMaticView?.request.testModeEnabled = params.testMode
        pubMaticView?.request.debug = params.debugLogs
        pubMaticView?.request.bidSummaryEnabled = params.bidSummaryLogs
        
        pubMaticView?.loadAd()
        self.bannerView = pubMaticView
        let delegate = self.delegate ?? makePubMaticViewDelegate(adType: adType,
                                                                 containerViewController: containerViewController,
                                                                 receiveAdSuccessCompletion: receiveAdSuccessCompletion,
                                                                 receiveAdErrorCompletion: receiveAdErrorCompletion)
        self.delegate = delegate
        self.bannerView?.delegate = delegate
        self.adType = adType
        self.titleLabel = makeTitleLabel(adTitleLabelText)
        self.inUnitBackgroundColor = inUnitBackgroundColor
        self.onAdRemovalCompletion = onAdRemovalCompletion
        self.timeInView = params.timeInView
    }
    
    func show(in containerView: UIView) {
        guard let pubMaticView = bannerView, let adType = adType, superview == nil else {
            return
        }
        containerView.addSubview(self)
        self.bannerView?.isHidden = true
        addSubview(pubMaticView)
        bringSubviewToFront(pubMaticView)
        
        self.containerView = containerView
        var constraints: [NSLayoutConstraint] = []
        
        if let pubMaticViewTitleLabel = titleLabel {
            addSubview(pubMaticViewTitleLabel)
            pubMaticViewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            constraints = [pubMaticViewTitleLabel.leadingAnchor.constraint(equalTo: pubMaticView.leadingAnchor),
                           pubMaticViewTitleLabel.bottomAnchor.constraint(equalTo: pubMaticView.topAnchor)]
            pubMaticViewTitleLabel.isHidden = true
            bringSubviewToFront(pubMaticView)
        }
        
        
        if case .inUnit = adType {
            closeButton.isHidden = true
            addSubview(closeButton)
            bringSubviewToFront(closeButton)
        }
        
        NSLayoutConstraint.activate(constraints)
        pubMaticView.translatesAutoresizingMaskIntoConstraints = false
        pubMaticView.removeConstraints(pubMaticView.constraints)
        NSLayoutConstraint.activate(bannerViewLayoutConstraints(pubMaticView, containerView: containerView, type: adType))
    }
    
    @objc func hide() {
        if pubMaticViewTimer != nil {
            pubMaticViewTimer?.invalidate()
            pubMaticViewTimer = nil
        }
        removeFromSuperview()
    }
    
    func refresh() {
        bannerView?.forceRefresh()
    }
}

private extension APEPubMaticBannerView {

    func makePubMaticViewDelegate(
        adType: APEUnitView.PubMaticParams.AdType,
        containerViewController: UIViewController,
        receiveAdSuccessCompletion: @escaping (() -> Void),
        receiveAdErrorCompletion: @escaping ((Error?) -> Void)
    ) -> APEUnitView.PubMaticViewDelegate {
        .init(
            containerViewController: containerViewController,
            receiveAdSuccessCompletion: { [weak self] in
                guard let self = self else { return }
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
                var timeInView = self.timeInView
                if case .inUnit = self.adType {
                    timeInView = timeInView ?? 7
                    self.backgroundColor = self.inUnitBackgroundColor
                }
                self.bannerView?.isHidden = false
                self.titleLabel?.isHidden = false
                self.closeButton.isHidden = false
                
                guard self.pubMaticViewTimer == nil, let timeInView = timeInView else { return }
                self.pubMaticViewTimer = Timer.scheduledTimer(withTimeInterval: Double(timeInView), repeats: false) { _ in
                    self.onAdRemovalCompletion?(adType)
                }
                receiveAdSuccessCompletion()
            },
            receiveAdErrorCompletion: { [weak self] error in
                guard let self = self else { return }
                print(error?.localizedDescription ?? "")
                self.onAdRemovalCompletion?(adType)
                receiveAdErrorCompletion(error)
            })
    }
    
    func bannerViewLayoutConstraints(_ pubMaticView: POBBannerView, containerView: UIView, type: APEUnitView.PubMaticParams.AdType) -> [NSLayoutConstraint] {
        var constraints = [pubMaticView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0),
                           pubMaticView.widthAnchor.constraint(equalToConstant: type.size.width),
                           pubMaticView.heightAnchor.constraint(equalToConstant: type.size.height)]
        switch type {
        case .bottom:
            constraints += [pubMaticView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
        case .inUnit:
            constraints += [pubMaticView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
                            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor,
                                                                 constant: type.size.width/2 + 7),
                            closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor,
                                                                 constant: -type.size.height/2 - 7)
            ]
        }
        return constraints
    }
}
