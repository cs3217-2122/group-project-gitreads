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
