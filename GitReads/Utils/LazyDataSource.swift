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

    // Actor to handle synchronization of the fetching
    actor Value {
        private var _value: T?

        let fetcher: () async -> Result<T, Error>

        init(fetcher: @escaping () async -> Result<T, Error>) {
            self.fetcher = fetcher
        }

        var value: Result<T, Error> {
            get async {
                // if the data has been fetched, return it immediately
                if let _value = _value {
                    return .success(_value)
                }

                // otherwise we fetch the data. if we error, simply pass on the
                // error to the caller and do not store the result. otherwise,
                // we store the successful result for subsequent calls.
                let result = await fetcher()
                if case let .success(res) = result {
                    _value = res
                }

                return result
            }
        }
    }

    private var valueActor: Value

    init<Fetcher: DataFetcher>(fetcher: Fetcher) where Fetcher.Value == T {
        self.valueActor = Value(fetcher: fetcher.fetchValue)
    }

    var value: Result<T, Error> {
        get async {
            await valueActor.value
        }
    }

    func preload() {
        Task {
            _ = await valueActor.value
        }
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
