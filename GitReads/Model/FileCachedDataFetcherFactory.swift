//
//  FileCachedDataFetcherFactory.swift
//  GitReads

import Cache
import Foundation

struct CacheKey: Hashable {
    let platform: RepoPlatform
    let owner: String
    let repo: String
    let sha: String
}

typealias FileCachedDataFetcher<T> = CachedDataFetcher<CacheKey, T>

struct FileCachedDataFetcherFactory {

    static let DefaultCacheDiskConfig = DiskConfig(
        name: "file-contents",
        expiry: .date(Date().addingTimeInterval(30 * 86_400)), // 30 days
        maxSize: 2_000_000_000 // 2GB
    )

    static let DefaultCacheMemoryConfig = MemoryConfig(
        expiry: .date(Date().addingTimeInterval(30 * 60)), // 30 minutes
        countLimit: 50
    )

    private let cachedDataFetcherFactory: CachedDataFetcherFactory<CacheKey>

    init?(
        diskConfig: DiskConfig = DefaultCacheDiskConfig,
        memoryConfig: MemoryConfig = DefaultCacheMemoryConfig
    ) {
        do {
            let storage: Storage<CacheKey, String> = try Storage(
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

    init(storage: Storage<CacheKey, String>) {
        self.cachedDataFetcherFactory = CachedDataFetcherFactory(storage: storage)
    }

    func makeCachedDataFetcher<T> (
        key: CacheKey,
        fetcher:  @escaping () async -> Swift.Result<T, Error>
    ) -> CachedDataFetcher<CacheKey, T> where T: Codable {
        cachedDataFetcherFactory.makeCachedDataFetcher(key: key, fetcher: fetcher)
    }
}
