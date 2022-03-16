//
//  Directory.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Directory {
    var files: [File]
    var directories: [Directory]
    let name: String
}
