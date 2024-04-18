//
//  APEAniViewStrategy.swift
//  ApesterKit
//
//  Created by Michael Krotorio on 4/17/24.
//

import Foundation
import UIKit
///
///
///
import AdPlayerSDK
///
///
///
@objc(APEAniViewStrategy)
@objcMembers
final public class APEAniViewStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.aniview
    }
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEAniViewParameters.init(from: dictionary)
    }
    internal override func createAdProvider(
        params                      : APEAdParameters,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText            : String,
        inUnitBackgroundColor       : UIColor,
        GDPRConsent gdprString      : String?,
        onAdRemovalCompletion       : @escaping APEAdProvider.HandlerAdType,
        onAdRequestedCompletion     : @escaping APEAdProvider.HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping APEAdProvider.HandlerVoidType,
        receiveAdErrorCompletion    : @escaping APEAdProvider.HandlerErrorType
    ) -> APEAdProvider {
        
        let parameters = params as! APEAniViewParameters
        
        let provider = APEAdProvider(
            monetization: APEMonetization.aniview(params: parameters),
            delegate: delegate
        )
        
        provider.nativeDelegate = ApeAniViewDelegate.init(
            adProvider      : provider,
            container       : nil,
            receiveAdSuccess: { [provider] in
                provider.statusSuccess()
                provider.bannerView.onReceiveAdSuccess()
                receiveAdSuccessCompletion()
                
            },
            receiveAdError  : { [provider] mistake in
                provider.statusFailure()
                provider.bannerView.onReceiveAdError(mistake)
                receiveAdErrorCompletion(mistake)
            }
        )
        
        let banner = APEAdView(
            adTitleText          : adTitleLabelText,
            monetizationType     : provider.monetization,
            inUnitBackgroundColor: inUnitBackgroundColor,
            timeInView           : nil,
            onAdRemovalCompletion: onAdRemovalCompletion
        )
        
        // TODO: ARKADI - move this to a diffrent location to make the system load faster
        AdPlayer.initSdk(storeURL: URL(string: "https://apps.apple.com/us/app/apester-app/id6478967119")!)
        
        let tag = AdPlayerTagConfiguration(tagId: parameters.identifier)
        
        let publisher = AdPlayerPublisherConfiguration(publisherId: parameters.channelId, tagConfiguration: tag, nil)
        
        AdPlayer.initializePublisher(publisher)
        let placement: AdPlayerPlacementViewController = AdPlayerPlacementViewController(tagId: parameters.identifier)
        
        let nativeAdView = AdPlayerPlacementViewWrapper(viewController: placement )
        
        banner.adContent       = nativeAdView
        provider.bannerView    = banner
        provider.bannerContent = { [weak banner] in banner?.adContent }
        provider.refresh       = { [weak banner] in banner?.adContent?.forceRefreshAd() }
        provider.hide          = { [weak banner] in banner?.hideAd()  }
        provider.show          = { [weak banner] containerDisplay in
            
            guard let adBanner = banner else { return }
            
            if let nativeDelegate = provider.nativeDelegate {
                nativeDelegate.containerViewController = delegate.adPresentingViewController
                
                if let vc  = nativeDelegate.containerViewController {
                    //                let container = UIView()
                    adBanner.clipsToBounds = true
                    adBanner.translatesAutoresizingMaskIntoConstraints = false
                    adBanner.isUserInteractionEnabled = true
                    vc.view.addSubview(adBanner)
                    NSLayoutConstraint.activate([
                        adBanner.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                        adBanner.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
                        adBanner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
                    ])
                    
                    //                let closeButton = UIButton(type: .system)
                    //                closeButton.translatesAutoresizingMaskIntoConstraints = false
                    //                closeButton.setTitle("✖️", for: .normal)
                    //                closeButton.addTarget(vc, action: #selector(self.closeButtonTapped(_:)), for: .touchUpInside)
                    //                closeButton.isHidden = true
                    //                adBanner.addSubview(closeButton)
                    
                    placement.view.translatesAutoresizingMaskIntoConstraints = false
                    vc.addChild(placement)
                    adBanner.addSubview(placement.view)
                    NSLayoutConstraint.activate([
                        placement.view.leadingAnchor.constraint(equalTo: adBanner.leadingAnchor),
                        placement.view.trailingAnchor.constraint(equalTo: adBanner.trailingAnchor),
                        placement.view.topAnchor.constraint(equalTo: adBanner.topAnchor),
                        placement.view.bottomAnchor.constraint(equalTo: adBanner.bottomAnchor, constant: -1)
                    ])
                    //                NSLayoutConstraint.activate([
                    //                    closeButton.topAnchor.constraint(equalTo: adBanner.topAnchor, constant: 0),
                    //                    closeButton.leadingAnchor.constraint(equalTo: adBanner.leadingAnchor, constant: 0),
                    //                    closeButton.widthAnchor.constraint(equalToConstant: 30),
                    //                    closeButton.heightAnchor.constraint(equalToConstant: 30)
                    //                ])
                    
                    placement.didMove(toParent: vc)
                    //                closeButton.isHidden = false
                    //                adBanner.bringSubviewToFront(closeButton)
                    //                closeButton.alpha = 1.0
                    //                closeButton.isEnabled = true
                    adBanner.showAd(in: containerDisplay)
                }
                
                onAdRequestedCompletion()
            }
        }
        return provider
    }
    
//    @objc func closeButtonTapped(_ sender: UIButton){
//        print("close button tapped ")
//        sender.superview?.removeFromSuperview()
//    }
    
    
}
