//
//  FileParser.swift
//  GitReads
//
//  Created by Tan Kang Liang on 16/3/22.
//

enum ParseError: Error {
    case cannotParse
}

protocol FileParser {
    func parse(fileString: String) -> [Line]
}
