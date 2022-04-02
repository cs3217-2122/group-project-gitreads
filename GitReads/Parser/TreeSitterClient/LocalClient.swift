//
//  LocalClient.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

import SwiftTreeSitter

class LocalClient {
    static func getSTSTree(fileString: String, language: Language) throws -> STSTree {
        let stsLanguage = try STSLanguage(fromPreBundle: .init(rawValue: language.rawValue)!)
        let parser = STSParser(language: stsLanguage)
        return parser.parse(string: fileString, oldTree: nil)!
    }
}
