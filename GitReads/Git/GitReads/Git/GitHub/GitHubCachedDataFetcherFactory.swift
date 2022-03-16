//
//  GitHubCachedDataFetcherFactory.swift
//  GitReads

import Cache
import Foundation

struct GitHubCacheKey: Hashable {
    let owner: String
    let repo: String
    let sha: String
}

typealias GitHubCachedDataFetcher<T> = CachedDataFetcher<GitHubCacheKey, T>

struct GitHubCachedDataFetcherFactory {

    static let DefaultCacheDiskConfig = DiskConfig(
        name: "github",
        expiry: .date(Date().addingTimeInterval(14 * 86_400)), // 14 days
        maxSize: 1_000_000_000 // 1GB
    )

    static let DefaultCacheMemoryConfig = MemoryConfig(
        expiry: .date(Date().addingTimeInterval(30 * 60)), // 30 minutes
        countLimit: 30
    )

    private let cachedDataFetcherFactory: CachedDataFetcherFactory<GitHubCacheKey>

    init?(
        diskConfig: DiskConfig = DefaultCacheDiskConfig,
        memoryConfig: MemoryConfig = DefaultCacheMemoryConfig
    ) {
        do {
            let storage: Storage<GitHubCacheKey, String> = try Storage(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                transformer: TransformerFactory.forCodable(ofType: String.self)
            )
            self.init(storage: storage)
        } catch {
            print("Error initializing GitHub cache storage: \(error)")
            return nil
        }
    }

    init(storage: Storage<GitHubCacheKey, String>) {
        self.cachedDataFetcherFactory = CachedDataFetcherFactory(storage: storage)
    }

    func makeCachedDataFetcher<T> (
        key: GitHubCacheKey,
        fetcher:  @escaping () async -> Swift.Result<T, Error>
    ) -> CachedDataFetcher<GitHubCacheKey, T> where T: Codable {
        cachedDataFetcherFactory.makeCachedDataFetcher(key: key, fetcher: fetcher)
    }
}
