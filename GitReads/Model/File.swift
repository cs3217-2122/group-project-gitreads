//
//  File.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct File {
    let path: Path
    let language: Language
    let declarations: [String] // create another type
    var lines: LazyDataSource<[Line]>

    var name: String {
        path.lastPathComponent ?? ""
    }
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.path == rhs.path
    }
}
