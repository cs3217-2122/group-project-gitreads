//
//  PseudoParser.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class PseudoParser: FileParser {

    static func parse(fileString: String, includeDeclarations: Bool = true) async throws -> ParseOutput {
        let lines = fileString.split(separator: "\n", omittingEmptySubsequences: false)
            .enumerated()
            .map { idx, line in
                Line(
                    lineNumber: idx,
                    tokens: [Token(type: .otherType, value: String(line), startIdx: 0, endIdx: line.count)]
                )
            }

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: [],
                           scopes: []
        )
    }
}
