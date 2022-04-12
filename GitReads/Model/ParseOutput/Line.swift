//
//  Line.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Line: Codable {
    let lineNumber: Int
    let tokens: [Token]

    var content: String {
        tokens.map { $0.value }.joined()
    }
}

extension Line: CustomStringConvertible {
    var description: String {
        let tokenDescriptions = tokens.map { String(describing: $0) }
        return """
               {
                 lineNumber: \(lineNumber),
                 tokens: [
               \(tokenDescriptions.map { "    " + $0 }.joined(separator: "\n"))
                 ]
               }
               """
    }
}
