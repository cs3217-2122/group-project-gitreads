//
//  Repo.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Repo {
    let root: Directory
    let branch = "main"

    /// Accepts a visitor, calling its method for every directory and file that is present in the current repository.
    func accept(visitor: RepoVisitor) {
        visitDirectory(directory: root, visitor: visitor)
    }

    private func visitDirectory(directory: Directory, visitor: RepoVisitor) {
        visitor.visit(directory: directory)
        for file in directory.files {
            visitor.visit(file: file)
        }

        for dir in directory.directories {
            visitDirectory(directory: dir, visitor: visitor)
        }
    }
}
