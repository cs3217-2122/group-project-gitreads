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
