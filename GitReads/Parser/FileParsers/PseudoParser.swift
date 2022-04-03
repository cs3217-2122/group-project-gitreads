//
//  PseudoParser.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class PseudoParser {

    static func parse(fileString: String) -> [Line] {
        fileString.split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                Line(tokens: [Token(type: .otherType, value: String(line))])
            }
    }
}
