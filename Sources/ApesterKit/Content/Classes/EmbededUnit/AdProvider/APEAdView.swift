//
//  APEAdView.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 16/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//
import Foundation
import UIKit
///
///
///
internal class APEAdView : UIView
{
    // MARK: - data
    internal private(set) var monetization : APEMonetization

    // MARK: - display
    internal var containerView : APEContainerView?
    
    private var adContentSizeObservation: NSKeyValueObservation?

    
    private  var nativeAdConstraintHeight: NSLayoutConstraint?
    private  var nativeAdConstraintWidth : NSLayoutConstraint?
    
    // MARK: - display - elements
    private var timeInView: Int?
    private var titleLabel: UILabel
    private lazy var closeButton: UIButton = {

        var b = UIButton(type: .custom)
        b.setTitle("🅧", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.widthAnchor.constraint(equalToConstant: 30).isActive = true
        b.heightAnchor.constraint(equalToConstant: 30).isActive = true
        b.addTarget(self, action: #selector(hideAd), for: .touchUpInside)
        b.accessibilityIdentifier = "apesterInUnitBunnerCloseButton"
        b.accessibilityHint = NSLocalizedString("Tap Apester In Unit Close Button to dismiss In Unit ad", comment: "")
        return b
    }()

    // MARK: - AdContent - elements
    internal var adContent : (UIView & APENativeLibraryAdView)? {
        didSet {
            if let adContent = adContent as? AdPlayerPlacementViewWrapper {
                setupVideoAdContentSizeObservation(adContent)
            }
        }
    }
    private  var refreshTimer : Timer?
    
    // MARK: - special case
    private var inUnitBackgroundColor: UIColor

    // MARK: - Handlers
    internal private(set) var onReceiveAdSuccess    : APEAdProvider.HandlerVoidType!
    internal private(set) var onReceiveAdError      : APEAdProvider.HandlerErrorType!
    internal private(set) var onAdRemovalCompletion : APEAdProvider.HandlerAdType
    internal private(set) var onVideoComplete      : APEAdProvider.HandlerVoidType!
    
    

    // MARK: - Helper
    private var makeTitleLabel : (String) -> UILabel = {

        let label = UILabel()
        label.text = $0
        label.backgroundColor = .darkText.withAlphaComponent(0.25)
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .lightText
        label.sizeToFit()
        return label
    }

    // override var intrinsicContentSize : CGSize {
    //     guard let adContent = adContent else { return .zero }
    //     let adContainerHeight = adContent.nativeSize.height + titleLabel.bounds.height
    //     return .init(width: adContent.nativeSize.width, height: adContainerHeight)
    // }
    
    internal var creativeHeight : CGFloat {
        guard let adContent = adContent else { return .zero }
        let adContainerHeight = adContent.nativeSize.height + titleLabel.bounds.height
        return adContainerHeight
    }

    // MARK: - Initialization
    internal override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal init(
        adTitleText titleText: String,
        monetizationType type: APEMonetization,
        inUnitBackgroundColor color: UIColor,
        timeInView: Int?,
        onAdRemovalCompletion onAdRemoval:  @escaping APEAdProvider.HandlerAdType
    ) {
        self.monetization          = type
        self.titleLabel            = makeTitleLabel(titleText)
        self.timeInView            = timeInView
        self.inUnitBackgroundColor = color
        self.onAdRemovalCompletion = onAdRemoval
        super.init(frame: .zero)
        self.backgroundColor    = .clear
        self.onReceiveAdSuccess = { [weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.onAdSuccessAction()
            if let vidView = strongSelf.adContent as? AdPlayerPlacementViewWrapper {
                print(vidView.frame)
            }
            strongSelf.closeButton.isHidden = false
        }
        self.onReceiveAdError   = { [weak self] mistake in
            
            guard let strongSelf = self else { return }
            strongSelf.onAdErrorAction(mistake)
        }
        self.onVideoComplete = { [weak self] in
            guard let strongSelf = self else { return }
            guard let _ = strongSelf.adContent as? AdPlayerPlacementViewWrapper else { return }
            
            strongSelf.closeButton.isHidden = true
            strongSelf.titleLabel.isHidden = true
        }
        
    }

    // MARK: - lifecycle
    deinit {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
        self.adContent = nil
    }
    
    // MARK: - public API
    @objc
    internal func showAd(in container: APEContainerView) {
        
        // take action only if the `APEAdView` is not embeded in a container, and the `APEBannerView` contains an ad object
        guard !containerView.ape_isExist else { return }
//        guard !superview.ape_isExist     else { return }
        guard let adView = adContent     else { return }
        
        containerView = container

        container.ape_addSubview(self, with: UIView.anchorToContainer)

        [adView,titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0)
        }
        [adView,titleLabel,closeButton].forEach {
            $0.isHidden = true
        }
        if monetization.adType != .inUnitVideo {
        titleLabel.ape_anchor(view: adView, with: [
            equal(\.leadingAnchor) ,
            equal(\.topAnchor)
        ])}

        applyConstraintsToDisplay(with: adView)

        if monetization.adType == .inUnit {

            let offset = CGFloat(12.0)
            ape_addSubview(closeButton, with: [])
            closeButton.ape_anchor(view: adView, with: [
                equal(\.trailingAnchor, \.leadingAnchor, constant:  offset),
                equal(\.topAnchor     , \.bottomAnchor , constant: -offset)
            ])
        }
        if  monetization.adType == .inUnitVideo || monetization.adType == .interstitial {
            if let vidView = adView as? AdPlayerPlacementViewWrapper {
                print(vidView.childView?.bounds)
                let offset = CGFloat(2.0)
                let topOffset = CGFloat(110.0)
                
                ape_addSubview(closeButton, with: [])
                closeButton.ape_anchor(view: adView, with: [
                    equal(\.leadingAnchor, constant:  offset),
                    equal(\.topAnchor , constant: -topOffset)
                ])
                vidView.bringSubviewToFront(closeButton)
            }
//            let offset = CGFloat(2.0)
//            let topOffset = CGFloat(110.0)
//            
//            ape_addSubview(closeButton, with: [])
//            closeButton.ape_anchor(view: adView, with: [
//                equal(\.leadingAnchor, constant:  offset),
//                equal(\.topAnchor , constant: -topOffset)
//            ])
//            vidView.bringSubviewToFront(closeButton)
        }
    }
    
    @objc
    internal func hideAd() {
        
        refreshTimer?.invalidate()
        refreshTimer = nil
      
        adContent?.removeFromSuperview()
        adContent = nil
        
        removeFromSuperview()
        onAdRemovalCompletion(monetization)
    }
    
    private func onAdSuccessAction() {
        
        // Apply action only if the `APEBannerView` is embeded into some display element
        guard containerView.ape_isExist  else { return }
        guard superview.ape_isExist      else { return }
        guard superview == containerView else { return }
        guard let adView = adContent     else { return }
        
        update(constraint: nativeAdConstraintHeight, with: adView.nativeSize.height)
        update(constraint: nativeAdConstraintWidth , with: adView.nativeSize.width )
        
        adContent?.isHidden = false
        titleLabel.isHidden = false

        // Display a background is ad is pubMatic
        var timeInDisplay : Int? = timeInView
        
        if monetization.adType == .inUnit, monetization.adType == .inUnitVideo {
            timeInDisplay        = timeInDisplay ?? 7
            backgroundColor      = inUnitBackgroundColor
            closeButton.isHidden = false
        }
        
        // TODO: - ask Apester again whats the idea for the timeInView feature for inView Ads
        // // Run Timer with timeInView interval or 7 sec
        // guard let inDisplay = timeInDisplay , refreshTimer == nil else { return }
        //
        // refreshTimer = Timer.scheduledTimer(withTimeInterval: Double(inDisplay), repeats: false, block: { [weak self] timer in
        //
        //     guard let strongSelf = self else { return }
        //     strongSelf.onAdRemovalCompletion?(strongSelf.monetization)
        // })
    }
    private func onAdErrorAction(_ error: Error?) {
        
        onAdRemovalCompletion(monetization)
    }
    private func applyConstraintsToDisplay(with adView: UIView & APENativeLibraryAdView) {
        
        ape_anchor(view: self, with: [
            greaterOrEqualValue(\.heightAnchor, to: creativeHeight)
        ])

        let heightTemplate = equalValue(\.heightAnchor, to: adView.nativeSize.height)
        let  widthTemplate = equalValue(\.widthAnchor , to: adView.nativeSize.width )
        
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
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break

        case (.adMob, .companion):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.centerYAnchor, constant: 0)
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break

        case (.pubMatic, .bottom):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.bottomAnchor  )
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break

        case (.pubMatic, .inUnit):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.centerYAnchor, constant: 0)
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break

        case (.pubMatic, .companion):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor),
                equal(\.bottomAnchor)
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break
        case (.amazon, .bottom):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.bottomAnchor  )
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break

        case (.amazon, .inUnit):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor, constant: 0),
                equal(\.centerYAnchor, constant: 0)
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break

        case (.amazon, .companion):
            ape_anchor(view: adView, with: [
                equal(\.centerXAnchor),
                equal(\.bottomAnchor)
            ])
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break
        case (.aniview, .inUnitVideo):
            
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break
        case (.aniview, .interstitial):
            
            nativeAdConstraintHeight = adView.ape_anchorSelf(with: heightTemplate, priority: .required)
            nativeAdConstraintWidth  = adView.ape_anchorSelf(with:  widthTemplate, priority: .required)
            break
        case (.amazon(params: _), .inUnitVideo): break
        case (.pubMatic(params: _), .inUnitVideo): break
        case (.adMob(params: let params), .inUnitVideo): break
        case (.amazon(params: let params), .interstitial):
            // TODO: implememt interstitial
            break
        case (.pubMatic(params: let params), .interstitial):
            // TODO: implememt interstitial
            break
        case (.adMob(params: let params), .interstitial):
            // TODO: implememt interstitial
            break
        case (.aniview(params: let params), .inUnit):
            // NOT in use:
            break
        case (.aniview(params: let params), .bottom):
            break
        case (.aniview(params: let params), .companion):
            break
        }
    }
    
    private func update(constraint : NSLayoutConstraint?, with const: CGFloat) {
        
        guard let c = constraint else { return }
        c.isActive = false
        c.constant = const
        c.isActive = true
    }
    
    private func setupVideoAdContentSizeObservation(_ adContent: AdPlayerPlacementViewWrapper) {
        
         adContentSizeObservation = adContent.observe(\.frame, options: [.old, .new], changeHandler: { [weak self] (adContent, change) in
             guard let newSize = change.newValue else { return }
             if newSize.height > 0 {
                 self?.adContentHeightChanged(to: newSize)
             }
         })
     }
    
    func adContentHeightChanged(to newSize: CGRect){
        if let vidView = self.adContent as? AdPlayerPlacementViewWrapper, let aniview = vidView.childView {
            print(self.containerView?.frame)
            print(vidView.childView?.bounds)
            let offset = CGFloat(2.0)
            let topOffset = CGFloat(1.0)
            
            ape_addSubview(closeButton, with: [])
            ape_addSubview(titleLabel, with: [])
            NSLayoutConstraint.activate([
                        titleLabel.bottomAnchor.constraint(equalTo: aniview.topAnchor),
                        titleLabel.leadingAnchor.constraint(equalTo: aniview.leadingAnchor),
                    ])
            titleLabel.sizeToFit()
            closeButton.ape_anchor(view: aniview, with: [
                equal(\.leadingAnchor, constant:  offset),
                equal(\.topAnchor)
            ])
            vidView.bringSubviewToFront(closeButton)
        }
    }
}
