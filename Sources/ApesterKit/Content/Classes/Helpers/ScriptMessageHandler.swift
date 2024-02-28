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
internal class ScriptMessageHandler : NSObject
{
    internal weak var delegate : WKScriptMessageHandler?
    
    internal init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
}

extension ScriptMessageHandler : WKScriptMessageHandler
{
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

// MARK:- Private WKUserContentController Extension
extension WKUserContentController {

    internal func register(to scriptMessages: [String], delegate: WKScriptMessageHandler?)
    {
        guard let delegate = delegate else { return }
        
        scriptMessages.forEach {
            self.add(ScriptMessageHandler(delegate: delegate), name: $0)
        }
    }

    internal func unregister(from scriptMessages: [String])
    {
        
        scriptMessages.forEach {
            self.removeScriptMessageHandler(forName: $0)
        }
    }
    
    internal func addScript(params: [String: String])
    {
        guard let jsonParams = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else { return }
        
        guard let parsedParams = String(data: jsonParams, encoding: .utf8) else { return }
        
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
