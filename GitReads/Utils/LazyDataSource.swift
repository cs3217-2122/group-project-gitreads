//
//  LazyDataSource.swift
//  GitReads

import Foundation

protocol DataFetcher {
    associatedtype Value

    func fetchValue() async -> Result<Value, Error>
}

extension DataFetcher {
    func map<T>(_ transform: @escaping (Value) -> T) -> AnyDataFetcher<T> {
        AnyDataFetcher { (await fetchValue()).map(transform) }
    }

    func flatMap<T>(
        _ transform: @escaping (Value) -> Result<T, Error>
    ) -> AnyDataFetcher<T> {
        AnyDataFetcher { (await fetchValue()).flatMap(transform) }
    }
}

struct AnyDataFetcher<T>: DataFetcher {
    typealias Value = T

    let fetcher: () async -> Result<T, Error>

    init(fetcher: @escaping () async -> Result<T, Error>) {
        self.fetcher = fetcher
    }

    init<Fetcher: DataFetcher>(_ dataFetcher: Fetcher) where Fetcher.Value == T {
        self.fetcher = dataFetcher.fetchValue
    }

    func fetchValue() async -> Result<T, Error> {
        await fetcher()
    }
}

class LazyDataSource<T> {

    private enum FetchStatus {
        case notFetched
        case inProgress(Task<T, Error>)
        case fetched(value: T)
    }

    // Actor to handle synchronization of the fetching
    private actor ValueFetcher {
        private var status: FetchStatus = .notFetched

        let fetcher: () async -> Result<T, Error>

        init(fetcher: @escaping () async -> Result<T, Error>) {
            self.fetcher = fetcher
        }

        var value: Result<T, Error> {
            get async { await fetch() }
        }

        private func fetch() async -> Result<T, Error> {
            switch status {
            case let .fetched(value):
                // if the data has been fetched, return it immediately
                return .success(value)

            case let .inProgress(task):
                // if the data is being fetched, wait for the results
                // of the in-progress fetch then return it
                return await task.result

            case .notFetched:
                // otherwise we fetch the data in a task and set the
                // status to in-progress
                let task = Task { try (await fetcher()).get() }
                status = .inProgress(task)

                let result = await task.result
                // if we error, we pass on the error to the caller and set the
                // status back to notFetched so subsequent calls can retry.
                // otherwise, we set the status to fetched and store the results
                // for subsequent calls.
                switch result {
                case let .success(result):
                    status = .fetched(value: result)
                case .failure:
                    status = .notFetched
                }

                return result
            }
        }
    }

    private(set) var fetchedValue: Result<T, Error>?
    private var valueFetcher: ValueFetcher

    init(fetcherFunc: @escaping () async -> Result<T, Error>) {
        self.valueFetcher = ValueFetcher(fetcher: fetcherFunc)
    }

    init<Fetcher: DataFetcher>(fetcher: Fetcher) where Fetcher.Value == T {
        self.valueFetcher = ValueFetcher(fetcher: fetcher.fetchValue)
    }

    convenience init(value: T) {
        self.init { .success(value) }
    }

    var value: Result<T, Error> {
        get async {
            let val = await valueFetcher.value
            self.fetchedValue = val
            return val
        }
    }

    func preload(priority: TaskPriority = .low) {
        Task.detached(priority: priority) {
            _ = await self.valueFetcher.value
        }
    }

    func map<NewValue>(
        _ transform: @escaping (T) async -> NewValue
    ) -> LazyDataSource<NewValue> {
        LazyDataSource<NewValue> { await self.value.asyncMap(transform) }
    }

    // Not technically a flatMap, but accepting a closure that returns
    // a result type instead of another lazy data source has better
    // ergonomics.
    func flatMap<NewValue>(
        _ transform: @escaping (T) async -> Result<NewValue, Error>
    ) -> LazyDataSource<NewValue> {
        LazyDataSource<NewValue> { await self.value.asyncFlatMap(transform) }
    }

    func flatMap<Fetcher: DataFetcher>(
        _ transform: @escaping (T) -> Fetcher
    ) -> LazyDataSource<Fetcher.Value> {
        LazyDataSource<Fetcher.Value> {
            await self.value.asyncFlatMap { val in
                let fetcher = transform(val)
                return await fetcher.fetchValue()
            }
        }
    }
}
