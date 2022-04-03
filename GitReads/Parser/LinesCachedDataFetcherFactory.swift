//
//  FileCachedDataFetcherFactory.swift
//  GitReads

import Cache
import Foundation

struct LinesCacheKey: Hashable {
    let platform: RepoPlatform
    let owner: String
    let repo: String
    let sha: String
}

typealias LinesCachedDataFetcher<T> = CachedDataFetcher<LinesCacheKey, T>

struct LinesCachedDataFetcherFactory {

    static let DefaultCacheDiskConfig = DiskConfig(
        name: "lines-cache",
        expiry: .date(Date().addingTimeInterval(30 * 86_400)), // 30 days
        maxSize: 2_000_000_000 // 2GB
    )

    static let DefaultCacheMemoryConfig = MemoryConfig(
        expiry: .date(Date().addingTimeInterval(30 * 60)), // 30 minutes
        countLimit: 100
    )

    private let cachedDataFetcherFactory: CachedDataFetcherFactory<LinesCacheKey>

    init?(
        diskConfig: DiskConfig = DefaultCacheDiskConfig,
        memoryConfig: MemoryConfig = DefaultCacheMemoryConfig
    ) {
        do {
            let storage: Storage<LinesCacheKey, String> = try Storage(
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

    init(storage: Storage<LinesCacheKey, String>) {
        self.cachedDataFetcherFactory = CachedDataFetcherFactory(storage: storage)
    }

    func makeCachedDataFetcher<T> (
        key: LinesCacheKey,
        fetcher:  @escaping () async -> Swift.Result<T, Error>
    ) -> CachedDataFetcher<LinesCacheKey, T> where T: Codable {
        cachedDataFetcherFactory.makeCachedDataFetcher(key: key, fetcher: fetcher)
    }
}
