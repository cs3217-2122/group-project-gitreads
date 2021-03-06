//
//  RepoVisitorTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

class RepoVisitorTests: XCTestCase {

    class DirectoryCounter: RepoVisitor {
        private(set) var count = 0

        func visit(directory: Directory) {
            count += 1
        }

        func visit(file: File) {}
    }

    class FileCounter: RepoVisitor {
        private(set) var count = 0

        func visit(file: File) {
            count += 1
        }

        func visit(directory: Directory) {}
    }

    func testVisitsAllFiles() {
        let visitor = FileCounter()
        MockRepo.repo.accept(visitor: visitor)
        XCTAssertEqual(visitor.count, 8)
    }

    func testVisitsAllDirectories() {
        let visitor = DirectoryCounter()
        MockRepo.repo.accept(visitor: visitor)
        XCTAssertEqual(visitor.count, 4)
    }

}
