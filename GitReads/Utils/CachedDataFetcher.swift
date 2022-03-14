//
//  CachedDataFetcher.swift
//  GitReads

import Cache
import Foundation

/// CachedDataFetcher wraps another data fetcher, with a given key, and get and set functions to access
/// a cache. When the value of the data is fetched, the cache will first be checked via the given key.
/// Only if the value in the cache is not available, will the wrapped data fetcher be called. The returned
/// successful result will then be stored in the cache.
struct CachedDataFetcher<Key: Hashable, T>: DataFetcher {
    typealias Value = T

    let key: Key
    let get: (Key) async -> Value?
    let set: (Key, Value) async -> Void
    let fetcher: () async -> Swift.Result<T, Error>

    func fetchValue() async -> Swift.Result<Value, Error> {
        // First check the cache to see if the value exists for the given key
        if let value = await get(key) {
            return .success(value)
        }

        let result = await fetcher()
        return result.map { value in
            // if successful, save the result in the cache asynchronously
            Task { await set(key, value) }
            return value
        }
    }

}

class CachedDataFetcherFactory<Key: Hashable> {
    private let storage: Storage<Key, String>

    init(storage: Storage<Key, String>) {
        self.storage = storage
    }

    func makeCachedDataFetcher<T> (
        key: Key,
        fetcher:  @escaping () async -> Swift.Result<T, Error>
    ) -> CachedDataFetcher<Key, T> where T: Codable {
        let typedStorage = storage.transformCodable(ofType: T.self)

        return CachedDataFetcher(
            key: key,
            get: { key in
                let result = await withCheckedContinuation { continuation in
                    typedStorage.async
                        .object(forKey: key) { continuation.resume(returning: $0) }
                }

                switch result {
                case let .value(value):
                    return value

                case let .error(err):
                    if let storageErr = err as? StorageError, storageErr == StorageError.notFound {
                        return nil
                    }

                    let nsErr = err as NSError
                    if nsErr.code == NSFileReadNoSuchFileError {
                        return nil
                    }

                     print("Cached data fetcher for key \"\(key)\" getter error: \(err)")
                    return nil
                }
            },
            set: { key, value in
                let result = await withCheckedContinuation { continuation in
                    typedStorage.async
                        .setObject(value, forKey: key) { continuation.resume(returning: $0) }
                }

                if case let .error(err) = result {
                    print("Cached data fetcher for key \"\(key)\" setter error: \(err)")
                }
            },
            fetcher: fetcher
        )
    }
}
