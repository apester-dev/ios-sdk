//
//  APEBannerView.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 16/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import UIKit

class APEBannerView: UIView {
    
    var containerView: UIView?
    var containerViewConstraints: [NSLayoutConstraint] = []
    var titleLabel: UILabel?
    var inUnitBackgroundColor: UIColor = .clear
    var monetizationType: APEUnitView.Monetization
    var adView: UIView?
    var adViewTimer: Timer?
    var delegate: AnyObject?
    var timeInView: Int?
    var onAdRemovalCompletion: ((APEUnitView.Monetization) -> Void)?
    var onReceiveAdSuccess: (() -> Void)?
    var onReceiveAdError: ((Error?) -> Void)?
    
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
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        adTitleLabelText: String,
        monetizationType: APEUnitView.Monetization,
        inUnitBackgroundColor: UIColor,
        timeInView: Int?,
        containerViewController: UIViewController,
        onAdRemovalCompletion: ((APEUnitView.Monetization) -> Void)?
    ) {
        self.monetizationType      = monetizationType
        self.titleLabel            = makeTitleLabel(adTitleLabelText)
        self.inUnitBackgroundColor = inUnitBackgroundColor
        self.timeInView = timeInView
        super.init(frame: .zero)
        self.backgroundColor    = .clear
        self.onReceiveAdSuccess = { [weak self] in
            
            guard let self = self, self.superview == self.containerView else { return }
            if let containerView = self.containerView, let bannerView = self.adView {
                var constraints = self.containerViewConstraints
                self.removeConstraints(constraints)
                
                constraints = [
                    self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                    self.heightAnchor.constraint(equalTo: bannerView.heightAnchor,
                                                 constant: self.titleLabel?.bounds.height ?? 0)
                ]
                if case .inUnit = self.monetizationType.adType {
                    constraints  = [
                        self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                        self.topAnchor.constraint(equalTo: containerView.topAnchor),
                        self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                    ]
                }
                self.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(constraints)
                self.containerViewConstraints = constraints
            }
                // Display a background is ad is pubMatic
            var timeInView = self.timeInView
            if case .inUnit = self.monetizationType.adType {
                timeInView = timeInView ?? 7
                self.backgroundColor = self.inUnitBackgroundColor
            }
            self.adView?.isHidden = false
            self.titleLabel?.isHidden = false
            self.closeButton.isHidden = false
                // Run Timer with timeInView interval or 7 sec
            guard self.adViewTimer == nil, let timeInView = timeInView else { return }
            self.adViewTimer = Timer.scheduledTimer(withTimeInterval: Double(timeInView), repeats: false) { _ in
                
                self.onAdRemovalCompletion?(self.monetizationType)
            }
        }
        
        self.onReceiveAdError = { [weak self] error in
            guard let self = self else { return }
            print(error?.localizedDescription ?? "")
            self.onAdRemovalCompletion?(self.monetizationType)
        }
        self.onAdRemovalCompletion = onAdRemovalCompletion
    }
    
    deinit {
        self.adView = nil
        self.adViewTimer = nil
        self.delegate = nil
        self.onAdRemovalCompletion = nil
        self.onReceiveAdSuccess = nil
        self.onReceiveAdError = nil
    }
    
    func show(in containerView: UIView) {
        guard let adView = adView, superview == nil else {
            return
        }
        containerView.addSubview(self)
        self.adView?.isHidden = true
        addSubview(adView)
        bringSubviewToFront(adView)
        
        self.containerView = containerView
        var constraints: [NSLayoutConstraint] = []
        
        if let titleLabel = titleLabel {
            addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            constraints = [titleLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
                           titleLabel.bottomAnchor.constraint(equalTo: adView.topAnchor)]
            titleLabel.isHidden = true
            bringSubviewToFront(adView)
        }
        
        
        if case .inUnit = monetizationType.adType {
            closeButton.isHidden = true
            addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            constraints += [
                closeButton.leadingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -7),
                closeButton.bottomAnchor.constraint(equalTo: adView.topAnchor, constant: 7)
            ]
            bringSubviewToFront(closeButton)
        }
        
        NSLayoutConstraint.activate(constraints)
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.removeConstraints(adView.constraints)
        NSLayoutConstraint.activate(adViewLayoutConstraints(adView, containerView: containerView, type: monetizationType.adType))
    }
    
    @objc func hide() {
        if adViewTimer != nil {
            adViewTimer?.invalidate()
            adViewTimer = nil
        }
        adView?.removeFromSuperview()
        self.adView = nil
        self.removeFromSuperview()
        self.delegate = nil
        
        onAdRemovalCompletion?(monetizationType)
        onAdRemovalCompletion = nil
        
    }
}

private extension APEBannerView {
    
    func adViewLayoutConstraints(_ adView: UIView, containerView: UIView, type: APEUnitView.Monetization.AdType) -> [NSLayoutConstraint] {
        
        var constraints: [NSLayoutConstraint] = []
        
        switch monetizationType {
        case .pubMatic(params: let params):
            constraints = [adView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0),
                           adView.widthAnchor.constraint(equalToConstant: type.size.width),
                           adView.heightAnchor.constraint(equalToConstant: type.size.height)]
            
            switch params.adType {
            case .bottom:
                constraints += [adView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
            case .inUnit:
                constraints += [adView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0)]
            }
        case .adMob(params: let params):
            constraints = [adView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                           adView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)]
            switch params.adType {
            case .bottom:
                constraints += [adView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
                if params.isCompanionVariant {
                    constraints += [adView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
                } else {
                    constraints += [adView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
                }
            case .inUnit:
                constraints = [adView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0),
                               adView.widthAnchor.constraint(equalToConstant: type.size.width),
                               adView.heightAnchor.constraint(equalToConstant: type.size.height),
                               adView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0)]
            }
        }
        return constraints
    }
}
