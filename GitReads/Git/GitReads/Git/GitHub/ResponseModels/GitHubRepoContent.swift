//
//  GitHubRepoContent.swift
//  GitReads

import Foundation
import SwiftUI

enum GitHubRepoContent: Decodable {
    case directory(GitHubDirectoryContent)
    case file(GitHubFileContent)
    case submodule(GitHubSubmoduleContent)
    case symlink(GitHubSymlinkContent)
    case unsupported

    private enum SingularContentType: String, Decodable {
        case file
        case submodule
        case symlink
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        do {
            // try to decode as a directory first, which is an array of values
            let container = try decoder.singleValueContainer()
            let value = try container.decode(GitHubDirectoryContent.self)
            self = .directory(value)

        } catch DecodingError.typeMismatch {
            // otherwise, the data is a singular object, we extract the `type` key to
            // figure out which case to decode to.
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let contentType = try container.decodeIfPresent(SingularContentType.self, forKey: .type)

            switch contentType {
            case .some(.file):
                let fileContent = try GitHubFileContent(from: decoder)
                self = .file(fileContent)

            case .some(.submodule):
                let submoduleContent = try GitHubSubmoduleContent(from: decoder)
                self = .submodule(submoduleContent)

            case .some(.symlink):
                let symlinkContent = try GitHubSymlinkContent(from: decoder)
                self = .symlink(symlinkContent)

            case .none:
                self = .unsupported
            }
        }
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
        contentTypeFunc: (GitHubRepoSummaryContent.ContentType) -> GitContentType
    ) {
        self.type = contentTypeFunc(content.actualType)
        self.name = content.name
        self.path = content.path
        self.sha = content.sha
        self.htmlURL = content.htmlURL
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
