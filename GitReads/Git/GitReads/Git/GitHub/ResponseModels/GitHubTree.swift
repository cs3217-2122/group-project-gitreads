//
//  GitHubTree.swift
//  GitReads

import Foundation

struct GitHubTree: Codable {
    let sha: String
    let url: URL
    let objects: [GitHubObject]
    let truncated: Bool

    private enum CodingKeys: String, CodingKey {
        case sha
        case url
        case objects = "tree"
        case truncated
    }
}
