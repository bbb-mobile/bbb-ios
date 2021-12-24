//
//  WKWebView+.swift
//  BigBlueButton-RLP
//
//  Created by Anton Sarudko on 10.12.21.
//

import UIKit
import WebKit

extension WKWebView {
    static let canGoBackKey = "canGoBack"
    static let canGoForwardKey = "canGoForward"
    
    /// Type of HTML element to get from DOM
    enum ElementType {
        /// Window Element
        case window
        /// Class element
        case `class`
    }
    
    /// List of errors for WKWebView injection
    enum InjectionError: Error {
        /// The Listener is already added
        case listenerAlreadyAdded
    }
    
    /// Adds a event listener that will be call on WKScriptMessageHandler - didReceiveMessage
    /// - Parameters:
    ///   - elementID: The name of the element
    ///   - callbackID: The ID for the callback
    ///   - elementType: The type of element to get
    ///   - completion: Callback triggered went script has been appended to WKWebView
    func addEventListener(elementID: String, callbackID: String, elementType: ElementType, handler: WKScriptMessageHandler, completion: ((Error?)->Void)?) {
        let element: String
        
        switch elementType {
        case .window:
            element = "window"
        case .class:
            element = "document.getElementsByClassName('\(elementID)')[0]"
        }
        
        let scriptString = """
                function callback () {
                    console.log('\(callbackID) clicked!')
                    window.webkit.messageHandlers.\(callbackID).postMessage({
                        message: 'WKWebView-onClickListener-\(callbackID)'
                    });
                }
                
                \(element).addEventListener('click', callback);
                """
        
        if configuration.userContentController.userScripts.first(where: { $0.source == scriptString }) == nil {
            evaluateJavaScript(scriptString) { [weak self] (result, error) -> Void in
                guard let self = self else { return }
                
                if let error = error {
                    completion?(error)
                } else {
                    self.configuration.userContentController.removeScriptMessageHandler(forName: callbackID)
                    self.configuration.userContentController.add(handler, name: callbackID)
                    self.configuration.userContentController.addUserScript(WKUserScript(source: scriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
                }
            }
        } else {
            completion?(InjectionError.listenerAlreadyAdded)
        }
    }
}
