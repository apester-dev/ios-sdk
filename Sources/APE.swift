//
//  APE.swift
//  ApesterKit
//
//  Created by Hasan Sa on 13/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import WebKit

/**
 APEWebViewProtocol where UIWebView && WKWebView confirms to it
 */
public protocol APEWebViewProtocol {}

extension UIWebView: APEWebViewProtocol {}
extension WKWebView: APEWebViewProtocol {}

/**
 APEWebViewServiceResult enum
 * success
 * failure
 */
public enum APEResult<T> {
  /// success case with success param
  case success(T)
  /// failure case with error description
  case failure(String)
}
