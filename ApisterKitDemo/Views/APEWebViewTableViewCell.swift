//
//  APEWebViewTableViewCellDelegate.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import ApesterKit
import WebKit

protocol APEWebViewTableViewCellDelegate: NSObjectProtocol {
  func didUpdateApesterUnitHeight()
}


class APEWebViewTableViewCell: UITableViewCell {
  weak var delegate: APEWebViewTableViewCellDelegate?
  private let initialHeight: CGFloat = 400
  private var heightConstraint: NSLayoutConstraint?
  var webContentView : APEWebViewProtocol?

  fileprivate var didLoadContent = false

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  func setupWebContentView(webView: APEWebViewProtocol) {
    guard let webview = webView as? UIView else {
      return
    }
    
    self.webContentView = webView
    contentView.addSubview(webview)

    // Auto Layout
    let heightConstraint = webview.heightAnchor.constraint(equalToConstant: initialHeight)
    heightConstraint.priority = 999

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: webview.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: webview.bottomAnchor),
      webview.widthAnchor.constraint(equalTo: contentView.widthAnchor),
      heightConstraint
      ])

    self.heightConstraint = heightConstraint
    APEWebViewService.shared.register(bundle: Bundle.main, webView: webView, unitHeightHandler: { [weak self] (result) in
      switch result {
      case .success(let height):
        self?.heightConstraint?.constant = height
        self?.delegate?.didUpdateApesterUnitHeight()
      case .failure(let err):
        print(err)
      }
    })
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {

  }

  /// Starts loading the Mustache template and inserts the `mediaId`.
  func loadContent(with mediaId: String) {
    // The templated with the `mediaId` already injected.
    var sourceHTMLString: String? {
      return Mustache.render("Apester", data: ["mediaId": mediaId as AnyObject])
    }
    guard let sourceString = sourceHTMLString else { return }
    if let webview = webContentView as? UIWebView {
      webview.loadHTMLString(sourceString, baseURL: URL(string: "file://"))
    }
    if let webview = webContentView as? WKWebView {
      webview.loadHTMLString(sourceString, baseURL: URL(string: "file://"))
    }
  }

  func configure(mediaId: String, delegate: APEWebViewTableViewCellDelegate?) {
    guard !didLoadContent else { return }
    self.delegate = delegate
    self.loadContent(with: mediaId)
    didLoadContent = true
  }
}

