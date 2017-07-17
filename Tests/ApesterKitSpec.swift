//
//  ApesterKitSpec.swift
//  ApesterKit
//
//  Created by Hasan Sa on 12/07/17.
//  Copyright © 2017 Apester. All rights reserved.
//

import WebKit
import Quick
import Nimble
@testable import ApesterKit


class ApesterKitSpec: QuickSpec {
  
  
  class WebViewViewController: UIViewController {
    var webView: UIWebView?
    
    override func viewDidLoad() {
      super.viewDidLoad()
      self.webView = UIWebView(frame: self.view.frame)
    }
  }
  
  class WKWebViewViewController: UIViewController {
    var webView: WKWebView?
    
    override func viewDidLoad() {
      super.viewDidLoad()
      self.webView = WKWebView(frame: self.view.frame)
    }
  }
  
  override func spec() {
    
    let viewController = WKWebViewViewController()
    
    beforeEach {
      viewController.viewDidLoad()
      APEWebViewService.shared.register(with: viewController.webView!)
    }
    
    describe("ApesterKitSpec") {
      // 1
      context("webView registered successfully") {
        it("webview must be an instance of UIWebView") {
          
          waitUntil { done in
            APEWebViewService.shared.register(with: viewController.webView!) { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).to(beTruthy() as! Predicate<String>)
              }
              done()
            }
          }
        }
      }
      // 2
      context("webView did start load") {
        it("webViewService bundle id must has a valid value") {
          waitUntil { done in
            APEWebViewService.shared.webView(didStartLoad: viewController.classForCoder) { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).to(beTruthy() as! Predicate<String>)
              }
              done()
            }
          }
        }
      }
      // 3
      context("webView did finish load") {
        it("webViewService bundle id must has a valid value && webViewService webview must be an instance of UIWebView") {
          waitUntil { done in
            APEWebViewService.shared.webView(didFinishLoad: viewController.classForCoder) { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).to(beTruthy() as! Predicate<String>)
              }
              done()
            }
          }
        }
      }
      // 4
      context("webView did fail load") {
        it("webViewService bundle id must has a valid value && webViewService webview must be an instance of UIWebView") {
          waitUntil { done in
            APEWebViewService.shared.webView(didFailLoad: viewController.classForCoder, failuer: nil, completionHandler: { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).to(beTruthy() as! Predicate<String>)
              }
              done()
            })
          }
        }
      }
    }
  }
  
}
