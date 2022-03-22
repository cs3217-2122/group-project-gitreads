//
//  GitHubRepo.swift
//  GitReads

import Foundation

struct GitHubRepo: Codable {
    /// Example: 1296269
    let id: Int
    /// Example: "MDEwOlJlcG9zaXRvcnkxMjk2MjY5"
    let nodeID: String
    /// Example: "Hello-World"
    let name: String
    /// Example: "octocat/Hello-World"
    let fullName: String
    let isPrivate: Bool
    /// Example: "https://github.com/octocat/Hello-World"
    let htmlURL: URL
    /// Example: "This your first repo!"
    let description: String?

    /// Example: "master"
    let defaultBranch: String

    init(
        id: Int,
        nodeID: String,
        name: String,
        fullName: String,
        isPrivate: Bool,
        htmlURL: URL,
        description: String?,
        defaultBranch: String,
        owner: String
    ) {
        self.id = id
        self.nodeID = nodeID
        self.name = name
        self.fullName = fullName
        self.isPrivate = isPrivate
        self.htmlURL = htmlURL
        self.description = description
        self.defaultBranch = defaultBranch
        self._owner = GitHubRepoOwner(login: owner)
    }

    private let _owner: GitHubRepoOwner

    var owner: String {
        _owner.login
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case nodeID = "node_id"
        case name
        case fullName = "full_name"
        case isPrivate = "private"
        case htmlURL = "html_url"
        case description
        case defaultBranch = "default_branch"
        case _owner = "owner"
    }
}

struct GitHubRepoOwner: Codable {
    let login: String
}
