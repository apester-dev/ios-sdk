//
//  APEContainerViewInUnit.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/6/23.
//

import WebKit
import UIKit
import Foundation

@objc(APEContainerViewUnit)
@objcMembers
internal class APEContainerViewUnit : APEContainerView
{    
    // MARK: -
    internal var webContent : WKWebView! {
        didSet {
            adContentMain   = APEContainerView(frame: .zero)
            adContentBunner = APEContainerView(frame: .zero)
            applyCurrentAutoresizingMask()
            applyLayout()
            applyDebug()
        }
    }
    internal fileprivate(set) var adContentMain   : APEContainerView!
    internal fileprivate(set) var adContentBunner : APEContainerView!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyAutoresizingMask()
        applyBaseConstraint()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyAutoresizingMask()
        applyBaseConstraint()
    }
    
    private func applyCurrentAutoresizingMask() {
        self.webContent     .translatesAutoresizingMaskIntoConstraints = false
        self.adContentMain  .translatesAutoresizingMaskIntoConstraints = false
        self.adContentBunner.translatesAutoresizingMaskIntoConstraints = false
    }    
    
    // MARK: -
    fileprivate func applyLayout() {

        // webview
        ape_addSubview(webContent, with: UIView.anchorToContainer)

        // cpm
        ape_addSubview(adContentMain, with: UIView.anchorToContainer)

        // bottom - bunner - inside
        addSubview(adContentBunner)
        ape_anchor(view: adContentBunner, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
    }
    fileprivate func applyDebug() {
        return;
        // webContent      .backgroundColor = .red
        // adContentMain   .backgroundColor = .green.withAlphaComponent(CGFloat(0.3))
        // adContentBunner .backgroundColor = .brown
    }
    
    // MARK: -
    @discardableResult
    internal func applyPreviewHeight(
        _ heightInUnitContent: CGFloat
    ) -> CGFloat {
        return applyLayoutHeight(heightInUnitContent, CGFloat(0.0))
    }
    @discardableResult
    internal func applyLayoutHeight(
        _ heightInUnitContent: CGFloat,
        _ heightInUnitBanner: CGFloat
    ) -> CGFloat {
        displayHeight  = heightInUnitContent
        adBottomHeight = heightInUnitBanner
        return displayHeight ?? CGFloat(0.0)
    }
    internal func removeBannerViews() {
        adContentMain  .subviews.forEach { $0.removeFromSuperview() }
        adContentBunner.subviews.forEach { $0.removeFromSuperview() }
    }
    // MARK: - =========================================================================================================
    private var adBottomHeight: CGFloat? {
        get { adContentBunner.displayHeight }
        set {
            adContentBunner.displayHeight = newValue
        }
    }
}
