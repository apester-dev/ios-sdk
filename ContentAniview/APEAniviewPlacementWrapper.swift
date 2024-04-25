//
//  APEAniviewPlacementWrapper.swift
//  ApesterKit
//
//  Created by Michael Krotorio on 4/17/24.
//
import UIKit
import AdPlayerSDK

class AdPlayerPlacementViewWrapper: UIView, APENativeLibraryAdView {

    private weak var childView: UIView?

    func forceRefreshAd()  { /* NO OPERATION HERE */ }
    func proceedToTriggerLoadAd() { /* NO OPERATION HERE */ }
    
    // Dynamically returning the child view's size if it changes
    var nativeSize: CGSize {
        return childView?.bounds.size ?? .zero
    }

    init(viewController: AdPlayerPlacementViewController) {
        super.init(frame: .zero)
        self.childView = viewController.view  // Keep a reference to the child view
        self.addSubview(viewController.view)
        // Set the child view to match the size of this wrapper initially
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        // Optionally, adjust the size of this wrapper based on the child's size
        self.translatesAutoresizingMaskIntoConstraints = false
        if let size = childView?.bounds.size {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Consider overriding layoutSubviews if dynamic adjustments are needed
    override func layoutSubviews() {
        super.layoutSubviews()
        if let size = childView?.bounds.size {
            self.bounds.size = size
        }
    }
}
