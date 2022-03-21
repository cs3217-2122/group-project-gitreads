//
//  LazyDataSourceTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

class LazyDataSourceTests: XCTestCase {

    actor Count {
        var value = 0
        func inc() {
            value += 1
        }
    }

    func testLazyDataSource_onlyCalledWhenValueAccessed() async throws {
        var called = false
        let lazyDataSource = LazyDataSource<String> {
            called = true
            return .success("Hello")
        }

        XCTAssertFalse(called, "Should not be called immediately after initialization")

        let value = try? await lazyDataSource.value.get()
        XCTAssertEqual(value, "Hello", "Returned value should match")

        XCTAssertTrue(called, "Should be called after value is accessed")
    }

    func testLazyDataSource_onlyCalledOnceWithMultipleAccesses() async throws {
        let calledCount = Count()
        let lazyDataSource = LazyDataSource<Int> {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                await calledCount.inc()
                return .success(await calledCount.value)
            } catch {
                return .failure(error)
            }
        }

        // try fetching while the first fetch function is in progress
        await (1...10).concurrentForEach { _ in
            let value = try? await lazyDataSource.value.get()
            XCTAssertEqual(value, 1, "Returned value should match the the first fetch")
        }

        let count = await calledCount.value
        XCTAssertEqual(count, 1, "Fetcher should only be called 1 time")

        // try fetching again after the fetch function has returned
        let value = try? await lazyDataSource.value.get()
        XCTAssertEqual(value, 1, "Returned value should match the first fetch")

        XCTAssertEqual(count, 1, "Fetcher should only be called 1 time")
    }

    enum TestError: Error {
        case error
    }

    func testLazyDataSource_fetcherReturnError() async throws {
        actor TestActor {
            var count = 0

            func getValue() -> Result<Int, Error> {
                count += 1
                if count < 3 {
                    return .failure(TestError.error)
                }

                return .success(10)
            }
        }

        let testActor = TestActor()

        let lazyDataSource = LazyDataSource<Int> {
            await testActor.getValue()
        }

        for _ in 1...2 {
            let value = await lazyDataSource.value
            switch value {
            case .success:
                XCTFail("Lazy data source should return error on first two accesses")
            case .failure(let err as TestError):
                XCTAssertEqual(err, TestError.error, "Returned value should match")
            case .failure:
                XCTFail("Returned error type does not match")
            }
        }

        // try fetching again after the errors
        let value = try? await lazyDataSource.value.get()
        XCTAssertEqual(value, 10, "Should fetch until a successful result is returned")
    }

    func testLazyDataSource_preload() async throws {
        var called = false
        let lazyDataSource = LazyDataSource<String> {
            called = true
            return .success("Hello")
        }

        lazyDataSource.preload()
        try await Task.sleep(nanoseconds: 500_000_000) // wait half a second
        XCTAssertTrue(called, "Data source fetcher should be called")
    }

    func testLazyDataSource_map() async throws {
        let firstCount = Count()
        let secondCount = Count()

        let firstDataSource = LazyDataSource<Int> {
            await firstCount.inc()
            return .success(1)
        }

        let secondDataSource: LazyDataSource<String> = firstDataSource.map { val in
            await secondCount.inc()
            return String(describing: val)
        }

        var firstCountValue = await firstCount.value
        var secondCountValue = await secondCount.value

        XCTAssertEqual(firstCountValue, 0, "First fetcher should not be called yet")
        XCTAssertEqual(secondCountValue, 0, "Second fetcher should not be called yet")

        // try fetching from the mapped data source first
        let secondResult = try? await secondDataSource.value.get()
        XCTAssertEqual(secondResult, "1", "Returned value from mapped data source should match")

        firstCountValue = await firstCount.value
        secondCountValue = await secondCount.value

        XCTAssertEqual(firstCountValue, 1, "First fetcher should be called once")
        XCTAssertEqual(secondCountValue, 1, "Second fetcher should be called once")

        // try fetching from the orignal data source after the mapped one was fetched
        let firstResult = try? await firstDataSource.value.get()
        XCTAssertEqual(firstResult, 1, "Return value from original data source should match")

        firstCountValue = await firstCount.value
        XCTAssertEqual(firstCountValue, 1, "First fetecher should still be called only once")
    }
}
