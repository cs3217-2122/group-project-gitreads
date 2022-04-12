//
//  Token.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Token: Codable {
    let type: TokenType
    let value: String

    // Start index is inclusive
    let startIdx: Int
    // End index is exclusive
    let endIdx: Int
}
