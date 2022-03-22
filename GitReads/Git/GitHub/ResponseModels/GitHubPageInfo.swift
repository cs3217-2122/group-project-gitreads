//
//  GitHubPaginatedResponse.swift
//  GitReads

import Foundation

// enum GitHubPaginationError: Error {
//    case noLink(for: GitHubPaginationLinkType)
// }
//
// struct GitHubPaginatedResponse<T> {
//    typealias PageFetcher = (URL) async -> Result<(items: [T], linkHeader: String?), Error>
//    typealias ResponseFetcher = () async -> Result<GitHubPaginatedResponse<T>, Error>
//
//    let items: [T]
//
//    private let pageFetcher: PageFetcher
//
//    private var prevResponseFetcher: ResponseFetcher?
//    private var nextResponseFetcher: ResponseFetcher?
//
//    init(
//        items: [T],
//        linkHeader: String?,
//        pageFetcher: @escaping PageFetcher
//    ) {
//        self.items = items
//        self.pageFetcher = pageFetcher
//
//        guard let linkHeader = linkHeader else {
//            return
//        }
//
//        let (prev, next) = parseLinkHeader(linkHeader)
//        if let prev = prev {
//            self.prevResponseFetcher = prev
//        }
//
//        if let next = next {
//            self.nextResponseFetcher = next
//        }
//    }
//
//    var hasPrev: Bool {
//        prevResponseFetcher != nil
//    }
//
//    var hasNext: Bool {
//        nextResponseFetcher != nil
//    }
//
//    func prevPage() async -> Result<GitHubPaginatedResponse<T>, Error> {
//        guard let prevResponseFetcher = prevResponseFetcher else {
//            return .failure(GitHubPaginationError.noLink(for: .prev))
//        }
//
//        return await prevResponseFetcher()
//    }
//
//    func nextPage() async -> Result<GitHubPaginatedResponse<T>, Error> {
//        guard let nextResponseFetcher = prevResponseFetcher else {
//            return .failure(GitHubPaginationError.noLink(for: .next))
//        }
//
//        return await nextResponseFetcher()
//    }
//
//    func parseLinkHeader(_ header: String) -> (prev: ResponseFetcher?, next: ResponseFetcher?) {
//        let (prevUrl, nextUrl) = parseGitHubLinkHeader(header)
//        return (
//            prev: prevUrl.map { url in { await self.fetchPage(url: url) } },
//            next: nextUrl.map { url in { await self.fetchPage(url: url) } }
//        )
//    }
//
//    func fetchPage(url: URL) async -> Result<GitHubPaginatedResponse<T>, Error> {
//        let result = await pageFetcher(url)
//        return result.map { items, linkHeader in
//            GitHubPaginatedResponse(
//                items: items,
//                linkHeader: linkHeader,
//                pageFetcher: self.pageFetcher
//            )
//        }
//    }
//
// }

enum GitHubPaginationLinkType: String {
    case next
    case prev
}

struct GitHubPageInfo: PageInfo {
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
