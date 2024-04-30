import UIKit
import AdPlayerSDK

class AdPlayerPlacementViewWrapper: UIView, APENativeLibraryAdView {

    weak var childView: UIView?
    private var childViewSizeObservation: NSKeyValueObservation?

    func forceRefreshAd() { /* NO OPERATION HERE */ }
    func proceedToTriggerLoadAd() { /* NO OPERATION HERE */ }
    
    // Dynamically returning the child view's size if it changes
    var nativeSize: CGSize {
        return childView?.bounds.size ?? .zero
    }

    init(viewController: AdPlayerPlacementViewController) {
        super.init(frame: .zero)
        self.childView = viewController.view  // Keep a reference to the child view
        self.addSubview(viewController.view)

        // Set the child view to match the size of this wrapper
        setupChildViewConstraints()
        
        // Observe size changes
        observeChildViewSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupChildViewConstraints() {
        guard let childView = self.childView else { return }
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: self.topAnchor),
            childView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func observeChildViewSize() {
        childViewSizeObservation = childView?.observe(\.bounds, options: [.old, .new]) { [weak self] view, change in
            guard let newSize = change.newValue?.size else { return }
            if change.oldValue?.size != newSize {
                self?.updateWrapperSize(to: newSize)
            }
        }
    }

    private func updateWrapperSize(to size: CGSize) {
        // Update the frame of the wrapper to match the child view's size
        self.frame.size = size
        print("Updated wrapper size to: \(size)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the wrapper size matches the child view if it changes from other layout updates
        if let size = childView?.bounds.size, self.bounds.size != size {
            updateWrapperSize(to: size)
        }
    }

    deinit {
        // Remove observation when the object is deinitialized
        childViewSizeObservation?.invalidate()
    }
}
