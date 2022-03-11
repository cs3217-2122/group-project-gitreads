//
//  LazyDataSource.swift
//  GitReads

protocol DataFetcher {
    associatedtype Value

    func fetchValue() async -> Result<Value, Error>
}

struct LazyDataSource<T> {

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
        mutating get async {
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
    }

    mutating func preload() {
        let fetcher = fetcher
        let fetchedValue = fetchedValue

        Task {
            if await fetchedValue.value != nil {
                return
            }

            let result = await fetcher()
            guard case let .success(value) = result else {
                return
            }

            await fetchedValue.set(value: value)
        }
    }
}
