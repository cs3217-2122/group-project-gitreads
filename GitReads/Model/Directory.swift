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
    let name: String
}
