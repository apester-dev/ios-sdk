//
//  APEStripViewTestCase.swift
//  ApesterKitTests
//
//  Created by Hasan Sawaed Tabash on 11/18/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import XCTest

class APEStripViewTestCase: XCTestCase {

    func testStripStyleURLParamsSuccess() {
        let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": "",
                       "itemShape": "", "itemSize": "", "itemHasShadow": ""]
        let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: nil, background: nil)
        let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
        XCTAssertTrue(isSuperset, "to be True")
    }

    func testStripStyleURLParamsWithOptionsSuccess() {
        let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": "",
                       "itemShape": "", "itemSize": "", "itemHasShadow": "",
                       "itemTextColor": "", "stripBackground": ""]
        let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: .darkGray, background: .white)
        let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
        XCTAssertTrue(isSuperset, "to be True")
    }

    func testStripStyleURLParamsWithHeaderFailure() {
        let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": ""]
        let header = APEStripHeader(text: "My Test", size: 15.0, family: nil, weight: 300, color: .blue)
        let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: .darkGray, background: .white, header: header)
        let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
        XCTAssertFalse(isSuperset, "to be False")
    }

    func testStripStyleURLParamsWithHeaderSuccess() {
         let equalTo = ["paddingTop": "", "paddingLeft": "",  "paddingBottom": "", "paddingRight": "",
                        "itemShape": "", "itemSize": "", "itemHasShadow": "",
                        "itemTextColor": "", "stripBackground": "",
                        "headerText": "",
                        "horizontalHeaderPadding": "0",
                        "headerFontSize": "", "headerFontColor": "", "headerFontWeight": "", "headerLtr": ""]
        let header = APEStripHeader(text: "My Test", size: 15.0, family: nil, weight: 400, color: .blue)
         let style = APEStripStyle(shape: .round, size: .medium, padding: .zero, shadow: false, textColor: .darkGray, background: .white, header: header)
             let isSuperset = Set(equalTo.keys).isSuperset(of: Set(style.parameters.keys))
        XCTAssertTrue(isSuperset, "to be True")
    }
}
