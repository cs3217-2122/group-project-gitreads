//
//  PaginatedResponse.swift
//  GitReads

import Foundation

enum PaginationLinkType {
    case next
    case prev
}

enum PaginationError: Error {
    case noPage(for: PaginationLinkType)
}

struct PaginatedValue<Value> {
    let items: [Value]
    let prevUrl: URL?
    let nextUrl: URL?
}

struct PaginatedResponse<Value> {

    typealias PageFetcher<T> = (URL) async -> Result<PaginatedValue<T>, Error>

    let items: [Value]

    private let prevUrl: URL?
    private let nextUrl: URL?

    private let pageFetcher: PageFetcher<Value>

    init(
        items: [Value],
        pageFetcher: @escaping PageFetcher<Value>,
        prevUrl: URL? = nil,
        nextUrl: URL? = nil
    ) {
        self.items = items
        self.pageFetcher = pageFetcher

        self.prevUrl = prevUrl
        self.nextUrl = nextUrl
    }

    init(paginatedValue: PaginatedValue<Value>, pageFetcher: @escaping PageFetcher<Value>) {
        self.items = paginatedValue.items
        self.pageFetcher = pageFetcher

        self.prevUrl = paginatedValue.prevUrl
        self.nextUrl = paginatedValue.nextUrl
    }

    var hasPrev: Bool {
        prevUrl != nil
    }

    var hasNext: Bool {
        nextUrl != nil
    }

    func prevPage() async -> Result<PaginatedResponse<Value>, Error> {
        guard let prevUrl = prevUrl else {
            return .failure(PaginationError.noPage(for: .prev))
        }

        let result = await pageFetcher(prevUrl)
        return result.map {
            PaginatedResponse(paginatedValue: $0, pageFetcher: pageFetcher)
        }
    }

    func nextPage() async -> Result<PaginatedResponse<Value>, Error> {
        guard let nextUrl = nextUrl else {
            return .failure(PaginationError.noPage(for: .next))
        }

        let result = await pageFetcher(nextUrl)
        return result.map {
            PaginatedResponse(paginatedValue: $0, pageFetcher: pageFetcher)
        }
    }

    func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> PaginatedResponse<NewValue> {
        let newItems = items.map(transform)
        let newFetcher: PageFetcher<NewValue> = { url in
            let result = await pageFetcher(url)
            return result.map { paginatedValue in
                PaginatedValue(
                    items: paginatedValue.items.map(transform),
                    prevUrl: paginatedValue.prevUrl,
                    nextUrl: paginatedValue.nextUrl
                )
            }
        }

        return PaginatedResponse<NewValue>(
            items: newItems,
            pageFetcher: newFetcher,
            prevUrl: prevUrl,
            nextUrl: nextUrl
        )
    }
}
