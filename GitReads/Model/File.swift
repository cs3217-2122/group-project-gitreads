//
//  File.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct File {
    let path: Path
    let sha: String
    let language: Language
    var parseOutput: LazyDataSource<ParseOutput>

    var name: String {
        path.lastPathComponent ?? ""
    }

    func isReadme() -> Bool {
        name.caseInsensitiveCompare("README.md") == .orderedSame
    }
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.path == rhs.path
    }
}

extension File: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}
