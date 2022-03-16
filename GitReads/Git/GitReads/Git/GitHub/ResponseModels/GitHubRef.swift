//
//  GitHubRef.swift
//  GitReads

import Foundation

struct GitHubRef: Codable {
    let ref: String
    let nodeID: String
    /// URL to the ref resource on the GitHub API
    let url: URL
    let object: Object

    struct Object: Codable {
        let sha: String
        let type: GitObjectType
        /// URL to the resource for the exact referenced commit on the GitHub API
        let url: URL
    }

    private enum CodingKeys: String, CodingKey {
        case ref
        case nodeID = "node_id"
        case url
        case object
    }
}
