//
//  Repo.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

struct Repo {

    let name: String
    let owner: String
    let description: String

    let platform: RepoPlatform

    let defaultBranch: String
    let branches: [String]
    let currBranch: String

    let root: Directory

    let htmlURL: URL?

    init(
        name: String,
        owner: String,
        description: String,
        platform: RepoPlatform,
        defaultBranch: String,
        branches: [String],
        currBranch: String,
        root: Directory,
        htmlURL: URL? = nil
    ) {
        self.name = name
        self.owner = owner
        self.description = description
        self.platform = platform
        self.defaultBranch = defaultBranch
        self.branches = branches
        self.currBranch = currBranch
        self.root = root
        self.htmlURL = htmlURL
    }

    var fullName: String {
        "\(owner)/\(name)"
    }

    /// Accepts a visitor, calling its method for every directory and file that is present in the current repository.
    func accept<Visitor: RepoVisitor>(visitor: Visitor) -> Visitor.VisitorOutput {
        visitDirectory(directory: root, visitor: visitor)
        return visitor.afterVisit()
    }

    private func visitDirectory<Visitor: RepoVisitor>(directory: Directory, visitor: Visitor) {
        visitor.visit(directory: directory)
        for file in directory.files {
            visitor.visit(file: file)
        }

        for dir in directory.directories {
            visitDirectory(directory: dir, visitor: visitor)
        }
        visitor.afterVisit(directory: directory)
    }
}
