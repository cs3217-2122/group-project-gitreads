//
//  GitHubObject.swift
//  GitReads

import Foundation

struct GitHubObject: Codable {
    let path: String
    let mode: String
    let type: GitObjectType
    let sha: String
    let size: Int?
    let url: URL?
}

extension GitObject {
    init(from object: GitHubObject) {
        self.init(
            type: object.type,
            path: Path(string: object.path, separator: "/"),
            mode: object.mode,
            sha: object.sha,
            sizeInBytes: object.size
        )
    }
}
