//
//  APEContainerViewInUnit.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/6/23.
//
import Foundation
import UIKit
import WebKit
///
///
///
@objc(APEContainerViewUnit)
@objcMembers
internal class APEContainerViewUnit : APEContainerView
{    
    // MARK: -
    internal var webContent : WKWebView! {
        didSet {
            adContentMain   = APEContainerView(frame: .zero)
            adContentBanner = APEContainerView(frame: .zero)
            applyCurrentAutoresizingMask()
            applyLayout()
            applyDebug()
        }
    }
    internal fileprivate(set) var adContentMain   : APEContainerView!
    internal fileprivate(set) var adContentBanner : APEContainerView!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    internal override func commonInit() {
        applyAutoresizingMask()
        applyBaseConstraint()
    }
    
    private func applyCurrentAutoresizingMask() {
        self.webContent     .translatesAutoresizingMaskIntoConstraints = false
        self.adContentMain  .translatesAutoresizingMaskIntoConstraints = false
        self.adContentBanner.translatesAutoresizingMaskIntoConstraints = false
    }    
    
    // MARK: -
    fileprivate func applyLayout() {

        // webview
        ape_addSubview(webContent, with: UIView.anchorToContainer)

        // cpm
        ape_addSubview(adContentMain, with: UIView.anchorToContainer)

        // bottom - bunner - inside
        addSubview(adContentBanner)
        ape_anchor(view: adContentBanner, with: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
    }
    fileprivate func applyDebug() {
        return;
        // webContent      .backgroundColor = .red
        // adContentMain   .backgroundColor = .green.withAlphaComponent(CGFloat(0.3))
        // adContentBanner .backgroundColor = .brown
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
        adContentBanner.subviews.forEach { $0.removeFromSuperview() }
    }
    // MARK: - =========================================================================================================
    private var adBottomHeight: CGFloat? {
        get { adContentBanner.displayHeight }
        set {
            adContentBanner.displayHeight = newValue
        }
    }
}
