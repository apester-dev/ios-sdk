//
//  APEBannerView.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 16/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import UIKit

class APEBannerView : UIView
{
    // MARK: - Typealias
    typealias HandlerVoid   = () -> Void
    typealias HandlerError  = (Error?) -> Void
    typealias HandlerAdType = (APEUnitView.Monetization) -> Void
    
    // MARK: - data
    private(set) var monetization : APEUnitView.Monetization
    
    // MARK: - display
    var containerView : UIView?
    
    // MARK: - display - elements
    private var timeInView: Int?
    private var titleLabel: UILabel
    private lazy var closeButton: UIButton = {
        
        var button = UIButton(type: .custom)
        button.setTitle("🅧", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        return button
    }()
    
    // MARK: - AdContent - elements
    internal var adContent : UIView?
    internal var delegate  : AnyObject?
    private  var refreshTimer : Timer?
    
    // MARK: - special case
    private var inUnitBackgroundColor: UIColor
    
    // MARK: - Handlers
    private(set) var onReceiveAdSuccess    : HandlerVoid?
    private(set) var onReceiveAdError      : HandlerError?
    private(set) var onAdRemovalCompletion : HandlerAdType?
    
    // MARK: - Helper
    private var makeTitleLabel: (_ text: String) -> UILabel = { text in
        
        let label = UILabel()
        label.text = text
        label.backgroundColor = .darkText.withAlphaComponent(0.25)
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .lightText
        label.setNeedsLayout()
        label.layoutIfNeeded()
        return label
    }
    
    override var intrinsicContentSize : CGSize {
        let adContainerHeight = monetization.adType.height + titleLabel.bounds.height
        return .init(width: monetization.adType.width, height: adContainerHeight)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        adTitleLabelText: String,
        monetizationType type: APEUnitView.Monetization,
        inUnitBackgroundColor color: UIColor,
        timeInView: Int?,
        containerViewController: UIViewController,
        onAdRemovalCompletion: ((APEUnitView.Monetization) -> Void)?
    ) {
        self.monetization = type
        self.titleLabel   = makeTitleLabel(adTitleLabelText)
        self.inUnitBackgroundColor = color
        self.timeInView = timeInView
        super.init(frame: .zero)
        self.backgroundColor    = .clear
        self.onReceiveAdSuccess = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.onAdSuccessAction()
        }
        self.onReceiveAdError   = { [weak self] error in
            
            guard let strongSelf = self else { return }
            strongSelf.onAdRemovalCompletion?(strongSelf.monetization)
        }
        self.onAdRemovalCompletion = onAdRemovalCompletion
    }
    
    // MARK: - lifecycle
    deinit {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
        self.adContent = nil
        self.delegate = nil
        self.onAdRemovalCompletion = nil
        self.onReceiveAdSuccess = nil
        self.onReceiveAdError = nil
    }
    
    // MARK: - public API
    @objc func show(in container: UIView) {
        
        // take action only if the `APEBannerView` is not embeded in a container, and the `APEBannerView` contains an ad object
        guard superview == nil , let adView = adContent else { return }
        
        containerView = container
        
        // TODO: -
        container.ape_addSubview(self, with: UIView.anchorToContainer)
        
        [adView,titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0)
        }
        
        adView.isHidden      = true
        titleLabel.isHidden  = true
        closeButton.isHidden = true
        
        titleLabel.ape_anchor(view: adView, with: [
            equal(\.leadingAnchor) ,
            equal(\.topAnchor, \.bottomAnchor)
        ])
        titleLabel.setNeedsLayout()
        titleLabel.layoutIfNeeded()
        
        applyConstraintsTodisplay(with: adView)
        
        if monetization.adType == .inUnit {
            
            let offset = CGFloat(12.0)
            ape_addSubview(closeButton, with: [])
            closeButton.ape_anchor(view: adView, with: [
                equal(\.trailingAnchor, \.leadingAnchor, constant:  offset),
                equal(\.topAnchor     , \.bottomAnchor , constant: -offset)
            ])
        }
    }
    
    @objc func hide() {
        
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        [closeButton,titleLabel,adContent,self].forEach { $0?.removeFromSuperview() }
        adContent = nil
        delegate  = nil
        
        onAdRemovalCompletion?(monetization)
        onAdRemovalCompletion = nil
    }
}
fileprivate extension APEBannerView {
    
    func applyConstraintsTodisplay(with adView: UIView) {
        
        let adContainerHeight = monetization.adType.height + titleLabel.bounds.height
        ape_anchor(view: self, with: [
            greaterOrEqualValue(\.heightAnchor, to: adContainerHeight)
        ])
        
        switch (monetization, monetization.adType) {
        case (.adMob, .bottom):
            ape_anchor(view: adView, with: [
                equal(\.leadingAnchor ),
                equal(\.trailingAnchor),
                equal(\.bottomAnchor  )
            ])
            break
            
        case (.adMob, .inUnit):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.centerYAnchor, constant: 0)
            ])
            adView.ape_anchor(view: adView, with: [
                equalValue(\.widthAnchor , to: monetization.adType.width),
                equalValue(\.heightAnchor, to: monetization.adType.height)
            ])
            break
            
        case (.adMob, .companion):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.centerYAnchor, constant: 0)
            ])
            adView.ape_anchor(view: adView, with: [
                equalValue(\.widthAnchor , to: monetization.adType.width),
                equalValue(\.heightAnchor, to: monetization.adType.height)
            ])
            break
            
        case (.pubMatic, .bottom):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.leadingAnchor ),
                equal(\.trailingAnchor),
                equal(\.bottomAnchor  )
            ])
            adView.ape_anchor(view: adView, with: [
                equalValue(\.widthAnchor , to: monetization.adType.width),
                equalValue(\.heightAnchor, to: monetization.adType.height)
            ])
            break
            
        case (.pubMatic, .inUnit):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.centerYAnchor, constant: 0)
            ])
            adView.ape_anchor(view: adView, with: [
                equalValue(\.widthAnchor , to: monetization.adType.width),
                equalValue(\.heightAnchor, to: monetization.adType.height)
            ])
            break
            
        case (.pubMatic, .companion):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor),
                equal(\.bottomAnchor)
            ])
            adView.ape_anchor(view: adView, with: [
                equalValue(\.widthAnchor , to: monetization.adType.width),
                equalValue(\.heightAnchor, to: monetization.adType.height)
            ])
            break
        }
    }
    
    func onAdSuccessAction() {
        
        // Apply action only if the `APEBannerView` is embeded into some display element
        guard superview == containerView else { return }
        
        adContent?.isHidden = false
        titleLabel.isHidden = false
        
        // Display a background is ad is pubMatic
        var timeInDisplay : Int? = timeInView
        
        if monetization.adType == .inUnit {
            timeInDisplay        = timeInDisplay ?? 7
            backgroundColor      = inUnitBackgroundColor
            closeButton.isHidden = false
        }
        
        // Run Timer with timeInView interval or 7 sec
        guard let inDisplay = timeInDisplay , refreshTimer == nil else { return }
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Double(inDisplay), repeats: false, block: { [weak self] timer in
            
            guard let strongSelf = self else { return }
            strongSelf.onAdRemovalCompletion?(strongSelf.monetization)
        })
    }
}
