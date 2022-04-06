//
//  ParseOutputCachedDataFetcherFactory.swift
//  GitReads

import Cache
import Foundation

struct ParseOutputCacheKey: Hashable {
    let platform: RepoPlatform
    let owner: String
    let repo: String
    let sha: String
}

typealias ParseOutputCachedDataFetcher<T> = CachedDataFetcher<ParseOutputCacheKey, T>

struct ParseOutputCachedDataFetcherFactory {

    static let DefaultCacheDiskConfig = DiskConfig(
        name: "parse-output-cache",
        expiry: .date(Date().addingTimeInterval(30 * 86_400)), // 30 days
        maxSize: 2_000_000_000 // 2GB
    )

    static let DefaultCacheMemoryConfig = MemoryConfig(
        expiry: .date(Date().addingTimeInterval(30 * 60)), // 30 minutes
        countLimit: 100
    )

    private let cachedDataFetcherFactory: CachedDataFetcherFactory<ParseOutputCacheKey>

    init?(
        diskConfig: DiskConfig = DefaultCacheDiskConfig,
        memoryConfig: MemoryConfig = DefaultCacheMemoryConfig
    ) {
        do {
            let storage: Storage<ParseOutputCacheKey, String> = try Storage(
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

    init(storage: Storage<ParseOutputCacheKey, String>) {
        self.cachedDataFetcherFactory = CachedDataFetcherFactory(storage: storage)
    }

    func makeCachedDataFetcher<T> (
        key: ParseOutputCacheKey,
        fetcher:  @escaping () async -> Swift.Result<T, Error>
    ) -> CachedDataFetcher<ParseOutputCacheKey, T> where T: Codable {
        cachedDataFetcherFactory.makeCachedDataFetcher(key: key, fetcher: fetcher)
    }
}
