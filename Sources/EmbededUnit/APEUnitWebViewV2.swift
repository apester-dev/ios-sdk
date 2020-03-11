//
//  APEUnitWebView.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation
import WebKit

@objcMembers public class APEUnitWebViewV2: NSObject {
    
    private var unitWebView: WKWebView!
    private var apeUnitWebViewDelegate: APEUnitWebViewDelegateV2!
    private var apeUnitSize: (widht: CGFloat, height: CGFloat)!
    
    public init(_ configuration: APEUnitConfiguration) {
        super.init()
        
        apeUnitWebViewDelegate = APEUnitWebViewDelegateV2(self, configuration.environment)
        
        let options = WKWebView.Options(events: [Constants.Unit.proxy],
                                        contentBehavior: .never,
                                        delegate: apeUnitWebViewDelegate)

        self.unitWebView = WKWebView.make(with: options)
        
        guard let unitUrl = configuration.unitURL else { return }
        
        unitWebView.load(URLRequest(url: unitUrl))
    }
    
    public func updateSize(_ size: ApeUnitSize) {
        
        self.unitWebView.translatesAutoresizingMaskIntoConstraints = false
        let containerViewHeightConstraint = unitWebView.heightAnchor.constraint(equalToConstant: size.height)
        containerViewHeightConstraint.priority = .defaultHigh
        containerViewHeightConstraint.isActive = true
        
        let width = min(size.width, UIScreen.main.bounds.size.width)
        let containerViewWidthConstraint = unitWebView.widthAnchor.constraint(equalToConstant: width)
        
        containerViewWidthConstraint.priority = .defaultHigh
        containerViewWidthConstraint.isActive = true
        
        guard let safeSuperview = unitWebView.superview else {
            return
        }
        
        unitWebView.topAnchor.constraint(equalTo: safeSuperview.topAnchor).isActive = true
        
        unitWebView.centerXAnchor.constraint(equalTo: safeSuperview.centerXAnchor).isActive = true
        
    }
    
    public func getWebView() -> WKWebView {
        return unitWebView
    }
}

extension APEUnitWebViewV2 {

    public struct ApeUnitSize {
        var width: CGFloat!
        var height: CGFloat!
        
        public init(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
        }
    }

}


// gallery - 5d3ff466640846006e46146e
// quiz 5d6527a40f10dd006186dbcd
//story 5ddeaa945d06ef005f3668e8
// like quiz 5d6523720f10dd006186dbc9
