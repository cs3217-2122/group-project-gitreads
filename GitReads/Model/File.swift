//
//  File.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct File {
    let name: String
    let language: Language // enum
    let declarations: [String] // create another type
    var lines: LazyDataSource<[Line]>
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.name == rhs.name
    }
}
