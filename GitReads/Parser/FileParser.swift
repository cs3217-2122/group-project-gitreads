//
//  FileParser.swift
//  GitReads
//
//  Created by Liu Zimu on 22/3/22.
//

struct FileParser {
    static func parseFile(fileString: String, language: Language) async throws -> [Line] {
        switch language {
        case .go:
            return try await GoParser.parse(fileString: fileString)
        case .html:
            return try await HtmlParser.parse(fileString: fileString)
        case .others:
            return PseudoParser.parse(fileString: fileString)
        }
    }

}
