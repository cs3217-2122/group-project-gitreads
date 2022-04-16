//
//  Declarations.swift
//  GitReads
//
//  Created by Liu Zimu on 5/4/22.
//

protocol Declaration: Codable {
    var start: [Int] { get set }
    var end: [Int] { get set }
    var identifier: String { get set }
}

struct DeclarationKey: Hashable {
    let start: [Int]
    let end: [Int]
    let identifier: String
}

extension Declaration {
    var key: DeclarationKey {
        DeclarationKey(start: start, end: end, identifier: identifier)
    }
}
