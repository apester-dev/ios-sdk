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

class ApesterKitSpec: QuickSpec {

  class WKWebViewViewController: UIViewController {
    var webView: WKWebView?

    override func viewDidLoad() {
      super.viewDidLoad()
      self.webView = WKWebView(frame: self.view.frame)
    }
  }

  override func spec() {
    describe("ApesterKitSpec") {
        let viewController = WKWebViewViewController()
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
    }

    describe("ApesterKitFastStripSpec") {
        context("strip style url params") {
            let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": "",
                           "itemShape": "", "itemSize": "", "itemHasShadow": ""]
            let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: nil, background: nil)
            it("1") {
                let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
                expect(isSuperset).to(beTrue())
            }
        }

        context("strip style url params with itemTextColor, stripBackground") {
            let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": "",
                           "itemShape": "", "itemSize": "", "itemHasShadow": "",
                           "itemTextColor": "", "stripBackground": ""]
            let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: .darkGray, background: .white)
            it("2") {
                let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
                expect(isSuperset).to(beTrue())
            }
        }

        context("strip style url params header") {
            let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": ""]
            let header = APEStripHeader(text: "My Test", size: 15.0, family: nil, weight: 300, color: .blue)
            let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: .darkGray, background: .white, header: header)
            it("3") {
                let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
                expect(isSuperset).to(beFalse())
            }
        }

        context("strip style url params header") {
             let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": "",
                            "itemShape": "", "itemSize": "", "itemHasShadow": "",
                            "itemTextColor": "", "stripBackground": "",
                            "headerText": "",
                            "headerFontSize": "", "headerFontColor": "", "headerFontWeight": "", "headerLtr": ""]
            let header = APEStripHeader(text: "My Test", size: 15.0, family: nil, weight: 400, color: .blue, isLTR: false)
             let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: .darkGray, background: .white, header: header)
             it("4") {
                 let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
                 expect(isSuperset).to(beTrue())
             }
         }
    }
  }
}
