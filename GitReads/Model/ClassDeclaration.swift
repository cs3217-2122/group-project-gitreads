//
//  ClassDeclaration.swift
//  GitReads
//
//  Created by Liu Zimu on 5/4/22.
//

struct ClassDeclaration: Codable, Declaration {
    var start: [Int]
    var end: [Int]
    var identifier: String
}
