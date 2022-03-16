//
//  GitHubRepoContent.swift
//  GitReads

import Foundation
import SwiftUI

enum GitHubRepoContent {
    case directory(GitHubDirectoryContent)
    case file(GitHubFileContent)
    case submodule(GitHubSubmoduleContent)
    case symlink(GitHubSymlinkContent)

    enum SingularContentType: String, Decodable {
        case file
        case submodule
        case symlink
    }
}

typealias GitHubDirectoryContent = [GitHubRepoSummaryContent]

/// When fetching a directory's content, the GitHub API provides an array of summary
/// representations of the resource, which excludes some attributes.
///
/// For more details, see:
/// https://docs.github.com/en/rest/overview/resources-in-the-rest-api#summary-representations
struct GitHubRepoSummaryContent: Codable {
    let type: ContentType
    let name: String
    let path: String
    let sha: String
    let size: Int

    let htmlURL: URL
    let downloadURL: URL?

    enum ContentType: String, Codable {
        case directory = "dir"
        case file
        case submodule
        case symlink
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case path
        case sha
        case size
        case htmlURL = "html_url"
        case downloadURL = "download_url"
    }

    /// GitHub's API appears to have a bug where submodules are labelled as files
    /// in their summary representation. To handle that, we can distinguish between
    /// actual files and submodules by checking if the `downloadURL` is nil.
    var actualType: ContentType {
        if type == .file && downloadURL == nil {
            return .submodule
        }

        return type
    }
}

extension GitContent {
    init(
        from content: GitHubRepoSummaryContent,
        contentTypeFunc: (GitHubRepoSummaryContent) -> GitContentType
    ) {
        self.type = contentTypeFunc(content)
        self.name = content.name
        self.path = Path(string: content.path, separator: "/")
        self.sha = content.sha
        self.sizeInBytes = content.size
    }
}

struct GitHubFileContent: Codable {
    let name: String
    let path: String
    let sha: String
    let size: Int

    let htmlURL: URL
    let downloadURL: URL?

    let content: String
    let encoding: Encoding

    private enum CodingKeys: String, CodingKey {
        case name
        case path
        case sha
        case size
        case htmlURL = "html_url"
        case downloadURL = "download_url"
        case content
        case encoding
    }

    enum Encoding: String, Codable {
        case base64
    }
}

struct GitHubSubmoduleContent: Codable {
    let name: String
    let path: String
    let sha: String
    let size: Int

    let htmlURL: URL
    let downloadURL: URL?

    let submoduleGitURL: URL

    private enum CodingKeys: String, CodingKey {
        case name
        case path
        case sha
        case size
        case htmlURL = "html_url"
        case downloadURL = "download_url"
        case submoduleGitURL = "submodule_git_url"
    }
}

struct GitHubSymlinkContent: Codable {
    let name: String
    let path: String
    let sha: String
    let size: Int

    let htmlURL: URL
    let downloadURL: URL?

    let target: String

    private enum CodingKeys: String, CodingKey {
        case name
        case path
        case sha
        case size
        case htmlURL = "html_url"
        case downloadURL = "download_url"
        case target
    }
}
