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
  var webContentView : WKWebView?
  weak var delegate: APEWebViewTableViewCellDelegate?

  private let initialHeight: CGFloat = 400
  private var heightConstraint: NSLayoutConstraint?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  func setupWebContentView(webView: WKWebView) {
    self.webContentView = webView
    contentView.addSubview(webView)

    // Auto Layout
    let heightConstraint = webView.heightAnchor.constraint(equalToConstant: initialHeight)
    heightConstraint.priority = UILayoutPriority(rawValue: 999)

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: webView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
      webView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
      heightConstraint
      ])

    self.heightConstraint = heightConstraint
    APEWebViewService.shared.register(bundle: Bundle.main, webView: webView, unitHeightHandler: { [weak self] (result) in
      switch result {
      case .success(let height):
        self?.heightConstraint?.constant = height
        self?.heightAnchor.constraint(equalToConstant: height).isActive = true
        self?.layoutIfNeeded()
        self?.delegate?.didUpdateApesterUnitHeight()
      case .failure(let err):
        print(err)
      }
    })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Starts loading the Mustache template and inserts the `mediaId`.
  private func loadContent(with mediaId: String) {
    // The templated with the `mediaId` already injected.
    var sourceHTMLString: String? {
      return nil// Mustache.render("Apester", data: ["mediaId": mediaId as AnyObject])
    }
    guard let sourceString = sourceHTMLString else { return }
    if let webview = webContentView {
      webview.loadHTMLString(sourceString, baseURL: URL(string: "file://"))
    }
  }

  func configure(mediaId: String, delegate: APEWebViewTableViewCellDelegate?) {
    self.delegate = delegate
    self.loadContent(with: mediaId)
  }
}

