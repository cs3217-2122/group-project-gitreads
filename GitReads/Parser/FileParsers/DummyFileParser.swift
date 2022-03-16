//
//  DummyFileParser.swift
//  GitReads
//
//  Created by Tan Kang Liang on 16/3/22.
//

struct DummyFileParser: FileParser {
    func parse(fileString: String, name: String) -> File? {
        var file = File(name: name, language: "any", declarations: [], lines: [])
        for line in fileString.split(separator: "\n") {
            file.lines.append(Line(tokens: [Token(type: .string, value: String(line))], indentLevel: 0))
        }
        return file
    }
}
