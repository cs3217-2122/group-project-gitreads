//
//  ResultExtensions.swift
//  GitReads

extension Result {
    func asyncMap<NewSuccess>(
        _ transform: (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(valueu):
            return .success(await transform(valueu))

        case let .failure(err):
            return .failure(err)
        }
    }

    func asyncFlatMap<NewSuccess>(
        _ transform: (Success) async -> Result<NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(value):
            return await transform(value)

        case let .failure(err):
            return .failure(err)
        }
    }
}
