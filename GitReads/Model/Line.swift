//
//  Line.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Line {
    let tokens: [Token]

    var content: String {
        tokens.map { $0.value }.joined()
    }
}
