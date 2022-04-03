//
//  ScreenViewModelTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

class ScreenViewModelTests: XCTestCase {
    var viewModel: ScreenViewModel!

    override func setUpWithError() throws {
        viewModel = ScreenViewModel()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    func testInit() {
        XCTAssertFalse(viewModel.showSideBar)
        XCTAssertEqual(viewModel.files, [])
        XCTAssertNil(viewModel.openFile)
    }

    func testToggleSideBar() {
        XCTAssertFalse(viewModel.showSideBar)
        viewModel.toggleSideBar()
        XCTAssertTrue(viewModel.showSideBar)
        viewModel.toggleSideBar()
        XCTAssertFalse(viewModel.showSideBar)
    }

    func testHideSideBar() {
        viewModel.toggleSideBar()
        XCTAssertTrue(viewModel.showSideBar)

        viewModel.hideSideBar()
        XCTAssertFalse(viewModel.showSideBar)
        viewModel.hideSideBar()
        XCTAssertFalse(viewModel.showSideBar)
    }

    func testOpenFile_addsFileToFiles_setsOpenFile() {
        viewModel.openFile(file: MockRepo.file1)
        XCTAssertEqual(viewModel.files, [MockRepo.file1])
        XCTAssertEqual(viewModel.openFile, MockRepo.file1)
    }

    func testOpenFile_multipleFiles_openFileIsMostRecentlyAdded() {
        viewModel.openFile(file: MockRepo.file1)
        viewModel.openFile(file: MockRepo.file2)
        viewModel.openFile(file: MockRepo.fileA1)
        viewModel.openFile(file: MockRepo.fileA2)
        XCTAssertEqual(viewModel.files, [MockRepo.file1, MockRepo.file2, MockRepo.fileA1, MockRepo.fileA2])
        XCTAssertEqual(viewModel.openFile, MockRepo.fileA2)
    }

    func testOpenFile_sameFile_onlyOneAdded() {
        viewModel.openFile(file: MockRepo.file1)
        viewModel.openFile(file: MockRepo.file1)
        viewModel.openFile(file: MockRepo.file1)
        XCTAssertEqual(viewModel.files, [MockRepo.file1])
        XCTAssertEqual(viewModel.openFile, MockRepo.file1)
    }

    func testRemoveFile_removesFromFiles_openFileIsNil() {
        viewModel.openFile(file: MockRepo.file1)
        XCTAssertEqual(viewModel.files, [MockRepo.file1])
        XCTAssertEqual(viewModel.openFile, MockRepo.file1)

        viewModel.removeFile(file: MockRepo.file1)
        XCTAssertEqual(viewModel.files, [])
        XCTAssertNil(viewModel.openFile)
    }

    func testRemoveFile_removeNonExistentFile_doesNothing() {
        viewModel.openFile(file: MockRepo.file1)
        viewModel.removeFile(file: MockRepo.file2)

        XCTAssertEqual(viewModel.files, [MockRepo.file1])
        XCTAssertEqual(viewModel.openFile, MockRepo.file1)
    }

    func testRemoveFile_multipleFiles() {
        viewModel.openFile(file: MockRepo.file1)
        viewModel.openFile(file: MockRepo.file2)
        viewModel.openFile(file: MockRepo.fileA1)
        viewModel.openFile(file: MockRepo.fileA2)

        XCTAssertEqual(viewModel.files.count, 4)
        viewModel.removeFile(file: MockRepo.file1)
        XCTAssertEqual(viewModel.files.count, 3)
        viewModel.removeFile(file: MockRepo.file2)
        XCTAssertEqual(viewModel.files.count, 2)
        viewModel.removeFile(file: MockRepo.fileA1)
        XCTAssertEqual(viewModel.files.count, 1)
        viewModel.removeFile(file: MockRepo.fileA2)
        XCTAssertEqual(viewModel.files.count, 0)
        XCTAssertNil(viewModel.openFile)
    }

    func testRemoveFile_removedOtherFile_openFileUnaffected() {
        viewModel.openFile(file: MockRepo.file1)
        viewModel.openFile(file: MockRepo.file2)

        viewModel.removeFile(file: MockRepo.file1)
        XCTAssertEqual(viewModel.openFile, MockRepo.file2)
    }

    func testRemoveFile_removedOpenFile_openFileSetToOther() {
        viewModel.openFile(file: MockRepo.file1)
        viewModel.openFile(file: MockRepo.file2)

        viewModel.removeFile(file: MockRepo.file2)
        XCTAssertEqual(viewModel.openFile, MockRepo.file1)
    }
}
