//
//  ScriptMessageHandler.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

// MARK:- ScriptMessageHandler Wrapper
class ScriptMessageHandler : NSObject, WKScriptMessageHandler {

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

    func register(to scriptMessages: [String], delegate: WKScriptMessageHandler?) {
        guard let delegate = delegate else { return }
        scriptMessages.forEach({
            self.add(ScriptMessageHandler(delegate: delegate), name: $0)
        })
    }

    func unregister(from scriptMessages: [String]) {
        scriptMessages.forEach({
            self.removeScriptMessageHandler(forName: $0)
        })
    }
    
    func addScript(params: [String: String]) {
        if let jsonParams = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
         let parsedParams = String(data: jsonParams, encoding: .utf8)!
         let js = """
                window.__getInitParams = () => {
                    return \(parsedParams);
                };
                window.postMessage({
                    type: \"\(Constants.Unit.initInAppParams)\",
                    params: \(parsedParams)
                }, '*');
            """
         let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
         self.addUserScript(script)
        }
    }
}
