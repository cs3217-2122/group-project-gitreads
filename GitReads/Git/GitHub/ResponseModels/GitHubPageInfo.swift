//
//  GitHubPaginatedResponse.swift
//  GitReads

import Foundation

enum GitHubPaginationLinkType: String {
    case next
    case prev
}

struct GitHubPageInfo {
    let prevUrl: URL?
    let nextUrl: URL?

    init(linkHeader: String) {
        let (prev, next) = parseGitHubLinkHeader(linkHeader)
        self.prevUrl = prev
        self.nextUrl = next
    }
}

/// Information on the format of the link header can be found here:
/// https://docs.github.com/en/rest/guides/traversing-with-pagination#basics-of-pagination
func parseGitHubLinkHeader(_ header: String) -> (prev: URL?, next: URL?) {
    let links = header.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

    var prevPageUrl: URL?
    var nextPageUrl: URL?

    for link in links {
        let parts = link.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }

        if parts.count < 2 {
            continue
        }

        let url = URL(string: parts[0].trimmingCharacters(in: ["<", ">"]))
        let linkType = parseGitHubLinkType(parts[1])

        guard let url = url, let linkType = linkType else {
            continue
        }

        if case .prev = linkType {
            prevPageUrl = url
        }

        if case .next = linkType {
            nextPageUrl = url
        }
    }

    return (prev: prevPageUrl, next: nextPageUrl)
}

func parseGitHubLinkType(_ str: String) -> GitHubPaginationLinkType? {
    let prefix = "rel="
    guard str.hasPrefix(prefix) else {
        return nil
    }

    let typeStr = String(str.dropFirst(prefix.count)).trimmingCharacters(in: ["\""])
    return GitHubPaginationLinkType(rawValue: typeStr)
}
