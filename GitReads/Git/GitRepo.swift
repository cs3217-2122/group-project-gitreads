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

struct GitRepoSummary {
    let owner: String
    let name: String

    let fullName: String
    let htmlURL: URL
    let description: String
    let defaultBranch: String
}
