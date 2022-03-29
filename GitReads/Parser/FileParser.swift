//
//  FileParser.swift
//  GitReads
//
//  Created by Liu Zimu on 22/3/22.
//

struct FileParser {
    static func parseFile(fileString: String, language: Language) async throws -> [Line] {
        switch language {
        case .others:
            return pseudoParse(fileString: fileString)
        default:
            return try await parse(fileString: fileString, language: language)
        }
    }

    static func pseudoParse(fileString: String) -> [Line] {
        fileString.split(separator: "\n")
            .map { line in
                Line(tokens: [Token(type: .others, value: String(line))])
            }
    }

    static func parse(fileString: String, language: Language) async throws -> [Line] {
        let rawTokens = try await WebApiClient.sendParsingRequest(fileString: fileString, language: language)
        return TokenConverter.rawTokensToFile(fileString: fileString,
                                              rawTokens: rawTokens)
    }
}
