//
//  FileBarViewModelTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

class FileBarViewModelTests: XCTestCase {
    let TEST_FILE = MockRepo.fileA1

    func testInit() {
        let viewModel = FileBarViewModel(file: TEST_FILE)

        XCTAssertEqual(viewModel.file, TEST_FILE)
    }

    func testSelectFileWithoutDelegateNoErrors() {
        let viewModel = FileBarViewModel(file: TEST_FILE)

        viewModel.onSelectFile()
    }

    func testDelegateIsNotCalledWhenNotSet() {
        let viewModel = FileBarViewModel(file: TEST_FILE)
        let delegate = MockDelegate()

        viewModel.onSelectFile()
        XCTAssertEqual(delegate.count, 0)
        XCTAssertEqual(delegate.files, [])
    }

    func testDelegateIsCalledWhenSet() {
        let viewModel = FileBarViewModel(file: TEST_FILE)
        let delegate = MockDelegate()
        viewModel.setDelegate(delegate: delegate)

        viewModel.onSelectFile()
        XCTAssertEqual(delegate.count, 1)
        XCTAssertEqual(delegate.files, [TEST_FILE])

        viewModel.onSelectFile()
        XCTAssertEqual(delegate.count, 2)
        XCTAssertEqual(delegate.files, [TEST_FILE, TEST_FILE])
    }
}
