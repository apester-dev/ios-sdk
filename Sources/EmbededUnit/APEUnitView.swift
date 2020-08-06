//
//  APEUnitWebView.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import WebKit

@objcMembers public class APEUnitView: APEView {
    
    private var unitWebView: WKWebView!

    public private(set) var configuration: APEUnitConfiguration!
    public weak var delegate: APEUnitViewDelegate?

    private var unitWebViewHeightConstraint: NSLayoutConstraint?
    private var unitWebViewWidthConstraint: NSLayoutConstraint?
    
    /// The view visibility status, update this property either when the view is visible or not.
    public override var isDisplayed: Bool {
        didSet {
            self.messageDispatcher
                .dispatchAsync(Constants.WebView.setViewVisibilityStatus(isDisplayed),
                               to: self.unitWebView)
        }
    }

    public override var height: CGFloat {
        guard self.loadingState.isLoaded else {
            return .zero
        }
        return self.loadingState.height
    }
    
    public init(configuration: APEUnitConfiguration) {
        super.init(configuration.environment)
        
        self.configuration = configuration
        let options = WKWebView.Options(events: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibity], contentBehavior: .never, delegate: self)
        
        self.unitWebView = WKWebView.make(with: options)
        
        if let unitUrl = configuration.unitURL {
            unitWebView.load(URLRequest(url: unitUrl))
        }
        
    }
    
    public override func display(in containerView: UIView, containerViewConroller: UIViewController) {
        // update unitWebView frame according to containerView bounds
        containerView.layoutIfNeeded()
        containerView.addSubview(self.unitWebView)
        unitWebView.translatesAutoresizingMaskIntoConstraints = false
        unitWebView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        unitWebView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        unitWebView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        unitWebViewHeightConstraint = constraint(for: unitWebView.heightAnchor, equalTo: containerView.heightAnchor)
        unitWebViewHeightConstraint?.priority = .defaultLow
        unitWebViewHeightConstraint?.isActive = true

        unitWebViewWidthConstraint = constraint(for: unitWebView.widthAnchor, equalTo: containerView.widthAnchor)
        unitWebViewWidthConstraint?.priority = .defaultLow
        unitWebViewWidthConstraint?.isActive = true

        super.display(in: containerView, containerViewConroller: containerViewConroller)
    }

    /// Remove the unit web view
    public override func hide() {
        self.unitWebView.removeFromSuperview()
    }
    
    public func setGdprString(_ gdprString: String) {
        
        self.configuration.gdprString = gdprString
        if let unitUrl = configuration.unitURL {
            unitWebView.load(URLRequest(url:unitUrl))
        }
        
    }
    
    /// Refresh unit content
    public override func refreshContent() {
        // should be implemented later.
    }

    deinit {
        hide()
        destroy()
    }
}

// MARK: - Override internal APIs
@available(iOS 11.0, *)
extension APEUnitView {

    override func orientationDidChangeNotification() {}

    override func open(url: URL, type: APEViewNavigationType) {
        // wait for shouldHandleURL callback
        let shouldHandleURL: Void? = self.delegate?.unitView?(self, shouldHandleURL: url, type: type) {
            if !$0 {
                self.open(url)
            }
        }
        // check if the shouldHandleURL is implemented
        if shouldHandleURL == nil {
            self.open(url)
        }
    }

    override func didFailLoading(error: Error) {
        self.destroy()
        self.delegate?.unitView(self, didFailLoadingUnit: self.configuration.unitParams.id)
    }

    override func didFinishLoading() {
        self.delegate?.unitView(self, didFinishLoadingUnit: self.configuration.unitParams.id)
    }

    // Handle UserContentController Script Messages
    override func handleUserContentController(message: WKScriptMessage) {
        let messageName = message.name
        if message.webView?.hash == self.unitWebView.hash,
            messageName == Constants.Unit.proxy,
            let bodyString = message.body as? String {

            if !loadingState.isLoaded {
                loadingState.isLoaded = true
            }

            if bodyString.contains(Constants.Unit.resize),
                let dictionary = bodyString.dictionary {
                let height = dictionary.floatValue(for: Constants.Unit.height)
                let width = dictionary.floatValue(for: Constants.Unit.width)
                if CGFloat(height) != self.loadingState.height {
                    self.loadingState.height = CGFloat(height)
                    if loadingState.isLoaded {
                        self.update(height: height, width: width)
                    }
                }
            }

            if bodyString.contains(Constants.WebView.apesterAdsCompleted){
                self.delegate?.unitView(self, didCompleteAdsForUnit: self.configuration.unitParams.id)
            }
        }

        if messageName == Constants.Unit.validateUnitViewVisibity {
            guard let containerVC = self.containerViewConroller, let view = self.containerView else {
                self.isDisplayed = false
                return
            }
            if containerVC.view.allSubviews.first(where: { $0 == view }) != nil {
                let convertedCenterPoint = view.convert(view.center, to: containerVC.view)
                self.isDisplayed = containerVC.view.bounds.contains(convertedCenterPoint)
            } else {
                self.isDisplayed = false
            }
        }
    }

    override func destroy() {
        self.unitWebView.configuration.userContentController
            .unregister(from: [Constants.Unit.proxy, Constants.Unit.validateUnitViewVisibity])
    }
}

private extension APEUnitView {
    func constraint(for anchor: NSLayoutDimension, equalTo: NSLayoutDimension) -> NSLayoutConstraint {
        anchor.constraint(equalTo: equalTo)
    }

    func constraint(for anchor: NSLayoutDimension, equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        anchor.constraint(equalToConstant: constant)
    }

    func update(height: CGFloat, width: CGFloat) {
        // 1 - update the stripWebView height constraint
        self.unitWebViewHeightConstraint.flatMap { NSLayoutConstraint.deactivate([$0]) }
        unitWebViewHeightConstraint = unitWebView.heightAnchor.constraint(equalToConstant: height)
        unitWebViewHeightConstraint?.priority = .defaultHigh
        unitWebViewHeightConstraint?.isActive = true

        // 2 - update the stripWebView width constraint
        self.unitWebViewWidthConstraint.flatMap { NSLayoutConstraint.deactivate([$0]) }
        unitWebViewWidthConstraint = unitWebView.widthAnchor.constraint(equalToConstant: height)
        unitWebViewWidthConstraint?.priority = .defaultHigh
        unitWebViewWidthConstraint?.isActive = true

        if let containerView = self.containerView {
            // 3 - update the strip containerView height constraint
            containerView.constraints
                .first(where: { $0.firstAttribute == .height })
                .flatMap { NSLayoutConstraint.deactivate([$0]) }
            let unitWebViewHeightConstraint = constraint(for: containerView.heightAnchor, equalToConstant: height)
            unitWebViewHeightConstraint.priority = .defaultHigh
            unitWebViewHeightConstraint.isActive = true

            // 4 - update the strip containerView width constraint
            containerView.constraints
                .first(where: { $0.firstAttribute == .width })
                .flatMap { NSLayoutConstraint.deactivate([$0]) }
            let unitWebViewWidthConstraint = constraint(for: containerView.widthAnchor, equalToConstant: width)
            unitWebViewWidthConstraint.priority = .defaultHigh
            unitWebViewWidthConstraint.isActive = true
        }

        // 5 - update the delegate about the new height
        self.delegate?.unitView(self, didUpdateHeight: height)
    }
}
