//
//  Scope.swift
//  GitReads

struct Scope: Codable {
    struct Index: Codable {
        let line: Int
        let char: Int
    }

    let prefixStart: Index
    let prefixEnd: Index
    let end: Index
}
