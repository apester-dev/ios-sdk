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
//@testable import ApesterKit

class ApesterKitSpec: QuickSpec {

  class WKWebViewViewController: UIViewController {
    var webView: WKWebView?

    override func viewDidLoad() {
      super.viewDidLoad()
      self.webView = WKWebView(frame: self.view.frame)
    }
  }

  override func spec() {
    let viewController = WKWebViewViewController()

    
    describe("ApesterKitSpec") {
      // 1
      context("Bundle registered successfully") {
        beforeEach {
          viewController.viewDidLoad()
        }
        it("Bundle must be an instance Bundle.main") {

          waitUntil { done in
            APEWebViewService.shared.register(bundle: Bundle.main, webView: viewController.webView!) { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).notTo(beNil())
              }
              done()
            }
          }
        }
      }
      // 2
      context("webView did start load") {
        beforeEach {
          viewController.viewDidLoad()
          APEWebViewService.shared.register(bundle: Bundle.main, webView: viewController.webView!)
        }
        it("webViewService bundle id must has a valid value") {
          waitUntil { done in
            APEWebViewService.shared.didStartLoad(webView: viewController.webView!) { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).notTo(beNil())
              }
              done()
            }
          }
        }
      }
      // 3
      context("webView did finish load") {
        beforeEach {
          viewController.viewDidLoad()
          APEWebViewService.shared.register(bundle: Bundle.main, webView: viewController.webView!)
        }
        it("webViewService bundle id must has a valid value") {
          waitUntil { done in
            APEWebViewService.shared.didFinishLoad(webView: viewController.webView!) { result in
              switch result {
              case .success(let res):
                expect(res).to(beTrue())
              case .failure(let err):
                expect(err).notTo(beNil())
              }
              done()
            }
          }
        }
      }
    }
  }
}
