//
//  DummyFileParser.swift
//  GitReads
//
//  Created by Tan Kang Liang on 16/3/22.
//

struct DummyFileParser: FileParser {
    func parse(fileString: String) -> [Line] {
        fileString.split(separator: "\n")
            .map { line in
                Line(tokens: [Token(type: .string, value: String(line))], indentLevel: 0)
            }
    }
}
