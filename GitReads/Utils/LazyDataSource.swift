//
//  LazyDataSource.swift
//  GitReads

protocol DataFetcher {
    associatedtype Value

    func fetchValue() async -> Result<Value, Error>
}

extension DataFetcher {
    func map<T>(_ transform: @escaping (Value) -> T) -> AnyDataFetcher<T> {
        AnyDataFetcher { (await fetchValue()).map(transform) }
    }

    func flatMap<T>(_ transform: @escaping (Value) -> Result<T, Error>) -> AnyDataFetcher<T> {
        AnyDataFetcher { (await fetchValue()).flatMap(transform) }
    }
}

struct AnyDataFetcher<T>: DataFetcher {
    typealias Value = T

    let fetcher: () async -> Result<T, Error>

    init(fetcher: @escaping () async -> Result<T, Error>) {
        self.fetcher = fetcher
    }

    func fetchValue() async -> Result<T, Error> {
        await fetcher()
    }
}

class LazyDataSource<T> {

    actor Value {
        var value: T?

        func `set`(value: T) {
            self.value = value
        }
    }

    private let fetcher: () async -> Result<T, Error>
    private var fetchedValue: Value

    init<Fetcher: DataFetcher>(fetcher: Fetcher) where Fetcher.Value == T {
        self.fetcher = fetcher.fetchValue
        self.fetchedValue = Value()
    }

    var value: Result<T, Error> {
        get async {
            await fetchValue()
        }
    }

    func preload() {
        let fetchValue = self.fetchValue

        Task {
            _ = await fetchValue()
        }
    }

    // TODO: may want to handle case where multiple fetches occur at
    // roughly the same time
    private func fetchValue() async -> Result<T, Error> {
        // if the data has been fetched, return it immediately
        if let data = await fetchedValue.value {
            return .success(data)
        }

        // otherwise we fetch the data. if we error, simply pass on the
        // error to the caller and do not store the result. otherwise,
        // we store the successful result for subsequent calls.
        let result = await fetcher()
        guard case let .success(value) = result else {
            return result
        }

        await fetchedValue.set(value: value)
        return .success(value)
    }

    func map<NewValue>(_ transform: @escaping (T) -> NewValue) -> LazyDataSource<NewValue> {
        let fetcher = AnyDataFetcher {
            await self.value.map(transform)
        }
        return LazyDataSource<NewValue>(fetcher: fetcher)
    }

    func flatMap<NewValue>(
        _ transform: @escaping (T) -> Result<NewValue, Error>
    ) -> LazyDataSource<NewValue> {
        let fetcher = AnyDataFetcher {
            await self.value.flatMap(transform)
        }
        return LazyDataSource<NewValue>(fetcher: fetcher)
    }
}
