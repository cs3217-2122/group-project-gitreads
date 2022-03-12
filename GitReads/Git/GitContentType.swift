//
//  GitContentType.swift
//  GitReads

struct GitFile {
    var contents: LazyDataSource<String>
}

struct GitDirectory {
    var contents: LazyDataSource<[GitContent]>
}

enum GitContentType {
    case file(GitFile)
    case directory(GitDirectory)
}
