//
//  FileNameSearchVisitorTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

class FileNameSearchVisitorTests: XCTestCase {

    func testNoSearchString() {
        let rootDir = search("")

        XCTAssertEqual(MockRepo.root.directories.count, rootDir.directories.count)
        XCTAssertEqual(MockRepo.root.files.count, rootDir.files.count)
    }

    func testNoMatchedFiles() {
        let rootDir = search("dirD")

        XCTAssertTrue(rootDir.files.isEmpty)
        XCTAssertTrue(rootDir.directories.isEmpty)
        XCTAssertEqual(rootDir.path, Path.root)
    }

    func testDirA() {
        let rootDir = search("dirA")

        XCTAssertEqual(rootDir.directories.count, 1)
        XCTAssertEqual(rootDir.files.count, 0)

        let dirA = rootDir.directories[0]
        assertDirsEqual(MockRepo.dirA, dirA)
    }

    func testDirB() {
        let rootDir = search("dirB")

        XCTAssertEqual(rootDir.directories.count, 1)
        XCTAssertEqual(rootDir.files.count, 0)

        let dirB = rootDir.directories[0]
        assertDirsEqual(MockRepo.dirB, dirB)
    }

    func testDirC() {
        let rootDir = search("dirC")

        XCTAssertEqual(rootDir.directories.count, 1)
        XCTAssertEqual(rootDir.files.count, 0)

        let dirC = rootDir.directories[0].directories[0]
        assertDirsEqual(MockRepo.dirC, dirC)
    }

    func testTextFiles() {
        let rootDir = search(".txt")

        XCTAssertEqual(rootDir.files.count, 2)
        // Dir A
        XCTAssertEqual(rootDir.directories[0].files.count, 1)
        // Dir B
        XCTAssertEqual(rootDir.directories[1].files.count, 1)
        // Dir C
        XCTAssertEqual(rootDir.directories[1].directories[0].files.count, 2)
    }

    func testGoFiles() {
        let rootDir = search(".go")

        XCTAssertEqual(rootDir.files.count, 0)
        // Dir A
        XCTAssertEqual(rootDir.directories[0].files.count, 1)
        // Dir B
        XCTAssertEqual(rootDir.directories[1].files.count, 0)
        // Dir C
        XCTAssertEqual(rootDir.directories[1].directories[0].files.count, 1)
    }

    private func search(_ text: String) -> Directory {
        MockRepo.repo.accept(visitor: FileNameSearchVisitor(searchText: text))
    }

    private func assertDirsEqual(_ dir1: Directory, _ dir2: Directory) {
        XCTAssertEqual(dir1.path, dir2.path)
        XCTAssertEqual(dir1.files.count, dir2.files.count)
        XCTAssertEqual(dir1.directories.count, dir2.directories.count)

        zip(dir1.files, dir2.files).forEach { XCTAssertEqual($0, $1) }
        zip(dir1.directories, dir2.directories).forEach { assertDirsEqual($0, $1) }
    }
}
