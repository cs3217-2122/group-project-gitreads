//
//  Directory.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Directory {
    let files: [File]
    let directories: [Directory]
    let path: Path

    var name: String {
        path.lastPathComponent ?? ""
    }

    /// Preloads the files in the directory up to the specified limit. The limit is mainly to avoid over-fetching
    /// in edge cases where the directory has thousands of files.
    func preloadFiles(limit: Int = 25) {
        for file in files.prefix(limit) {
            file.lines.preload()
        }
    }
}
