//
//  String+.swift
//  BigBlueButton-RLP
//
//  Created by Milan Bojic on 19.11.21..
//

import Foundation

extension String {
    var javaScriptString: String {
        var safeString  = self
        safeString      = safeString.replacingOccurrences(of: "\\", with: "\\\\")
        safeString      = safeString.replacingOccurrences(of: "\"", with: "\\\"")
        safeString      = safeString.replacingOccurrences(of: "\'", with: "\\\'")
        safeString      = safeString.replacingOccurrences(of: "\n", with: "\\n")
        safeString      = safeString.replacingOccurrences(of: "\r", with: "\\r")
        safeString      = safeString.replacingOccurrences(of: "\t", with: "\\t")
        safeString      = safeString.replacingOccurrences(of:"\u{0085}", with: "\\u{0085}")
        safeString      = safeString.replacingOccurrences(of:"\u{2028}", with: "\\u{2028}")
        safeString      = safeString.replacingOccurrences(of:"\u{2029}", with: "\\u{2029}")
        return safeString
    }
}
