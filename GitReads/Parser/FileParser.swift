//
//  FileParser.swift
//  GitReads
//
//  Created by Liu Zimu on 22/3/22.
//

protocol FileParser {
    static func parse(fileString: String, includeDeclarations: Bool) async throws -> ParseOutput
}
