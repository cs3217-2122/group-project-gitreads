//
//  GitContentType.swift
//  GitReads

import Foundation

struct GitDirectory {
    var contents: LazyDataSource<[GitContent]>
}

struct GitFile {
    var contents: LazyDataSource<String>
}

struct GitSubmodule {
    var gitURL: LazyDataSource<URL>
}

struct GitSymlink {
    var target: LazyDataSource<String>
}

enum GitContentType {
    case directory(GitDirectory)
    case file(GitFile)
    case submodule(GitSubmodule)
    case symlink(GitSymlink)
}
