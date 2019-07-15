//
//  APEScriptMessageHandler.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

// MARK:- APEScriptMessageHandler Wrapper
class APEScriptMessageHandler : NSObject, WKScriptMessageHandler {

    weak var delegate : WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

// MARK:- Private WKUserContentController Extension
extension WKUserContentController {

    func register(to scriptMessages: [String], delegate: WKScriptMessageHandler) {
        scriptMessages.forEach({
            self.add(APEScriptMessageHandler(delegate: delegate), name: $0)
        })
    }

    func unregister(from scriptMessages: [String]) {
        scriptMessages.forEach({
            self.removeScriptMessageHandler(forName: $0)
        })
    }

}
