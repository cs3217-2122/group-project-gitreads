//
//  GitRepo.swift
//  GitReads

import Foundation

struct GitRepo {
    let fullName: String
    let htmlURL: URL
    let description: String

    let defaultBranch: String
    let branches: [String]
    let currBranch: String

    let tree: GitTree
}

struct GitRepoSummary: Hashable {
    let owner: String
    let name: String

    let fullName: String
    let htmlURL: URL
    let description: String
    let defaultBranch: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(name)
    }
}
