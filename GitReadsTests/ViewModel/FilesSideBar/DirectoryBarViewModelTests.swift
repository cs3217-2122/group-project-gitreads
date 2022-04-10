//
//  DirectoryBarViewModelTests.swift
//  GitReadsTests
//
//  Created by Tan Kang Liang on 23/3/22.
//

import XCTest
@testable import GitReads
import SwiftUI

class DirectoryBarViewModelTests: XCTestCase {
    let TEST_DIRECTORY = MockRepo.dirA
    let TEST_NESTED_DIRECTORY = MockRepo.dirB
    let TEST_INNER_DIRECTORY = MockRepo.dirC
    let DIRECTORY_TO_BE_FLATTENED = Directory(
        files: [],
        directories: [
            Directory(
                files: [],
                directories: [
                    Directory(
                        files: [],
                        directories: [],
                        path: Path(string: "/level1/level2/level3")
                    )
                ],
                path: Path(string: "/level1/level2"))
        ],
        path: Path(string: "/level1")
    )

    func testUnnestedDirectoryInit() {
        let viewModel = DirectoryBarViewModel(directory: TEST_DIRECTORY)
        XCTAssertEqual(viewModel.path, TEST_DIRECTORY.path)
        XCTAssertEqual(viewModel.name, TEST_DIRECTORY.name)
        XCTAssertEqual(viewModel.files.count, 2)
        XCTAssertEqual(viewModel.directories.count, 0)
        XCTAssertFalse(viewModel.isOpen)
    }

    func testNestedDirectoryInit() {
        let viewModel = DirectoryBarViewModel(directory: TEST_NESTED_DIRECTORY)
        XCTAssertEqual(viewModel.path, TEST_NESTED_DIRECTORY.path)
        XCTAssertEqual(viewModel.name, TEST_NESTED_DIRECTORY.name)
        XCTAssertEqual(viewModel.files.count, 1)
        XCTAssertEqual(viewModel.directories.count, 1)
        XCTAssertFalse(viewModel.isOpen)

        XCTAssertEqual(viewModel.directories[0].path, TEST_INNER_DIRECTORY.path)
        XCTAssertEqual(viewModel.directories[0].name, TEST_INNER_DIRECTORY.name)
        XCTAssertEqual(viewModel.directories[0].files.count, 3)
        XCTAssertEqual(viewModel.directories[0].directories.count, 0)
        XCTAssertFalse(viewModel.directories[0].isOpen)
    }

    func testUnnestedDirectorySetDelegate() {
        let viewModel = DirectoryBarViewModel(directory: TEST_DIRECTORY)
        let delegate = MockDelegate()

        viewModel.setDelegate(delegate: delegate)
        selectAllFilesInDirectory(viewModel)

        XCTAssertEqual(delegate.files, TEST_DIRECTORY.files)
        XCTAssertEqual(delegate.count, 2)
    }

    func testNestedDirectorySetDelegate() {
        let viewModel = DirectoryBarViewModel(directory: TEST_NESTED_DIRECTORY)
        let delegate = MockDelegate()

        viewModel.setDelegate(delegate: delegate)
        selectAllFilesInDirectory(viewModel)

        XCTAssertEqual(delegate.files, TEST_NESTED_DIRECTORY.files + TEST_INNER_DIRECTORY.files)
        XCTAssertEqual(delegate.count, 4)
    }

    func testFlattensDirectory() {
        let viewModel = DirectoryBarViewModel(directory: DIRECTORY_TO_BE_FLATTENED)
        XCTAssertEqual(viewModel.name, "level1/level2/level3")
        let expectedDirectory = DIRECTORY_TO_BE_FLATTENED.directories[0].directories[0]
        XCTAssertEqual(viewModel.path, expectedDirectory.path)
        XCTAssertEqual(viewModel.directories.count, expectedDirectory.directories.count)
        XCTAssertEqual(viewModel.files.count, expectedDirectory.files.count)
    }

    private func selectAllFilesInDirectory(_ viewModel: DirectoryBarViewModel) {
        for file in viewModel.files {
            file.onSelectFile()
        }

        for dir in viewModel.directories {
            selectAllFilesInDirectory(dir)
        }
    }
}
