//
//  DirectoryStructureTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

class DirectoryStructureTests: XCTestCase {

    func testDirectoryStructure_element() {
        let testPaths = [
            Path(components: "a"),
            Path(components: "a", "b c"),
            Path(components: "b", "a") // not well formed
        ]

        let directoryStructure = DirectoryStucture(elements: testPaths, getPath: { $0 })

        let first = directoryStructure.element(at: Path(components: "a"))
        XCTAssertEqual(first, Path(components: "a"))

        let second = directoryStructure.element(at: Path(components: "a", "b c"))
        XCTAssertEqual(second, Path(components: "a", "b c"))

        let notFound = directoryStructure.element(at: Path(components: "b c"))
        XCTAssertNil(notFound)

        let notFound2 = directoryStructure.element(at: Path(components: "b", "a"))
        XCTAssertNil(notFound2)

        let notFound3 = directoryStructure.element(at: .root)
        XCTAssertNil(notFound3)
    }

    func testDirectoryStructure_childrenUnder() {
        let testPaths = [
            .root,
            Path(components: "a"),
            Path(components: "a", "b"),
            Path(components: "a", "c"),
            Path(components: "b", "b"), // not well formed
            Path(components: "a", "b", "c"),
            Path(components: "c")
        ]

        let directoryStructure = DirectoryStucture(elements: testPaths, getPath: { $0 })

        let rootChildren = directoryStructure.childrenUnder(path: .root)
        let rootExpected = Set([Path(components: "a"), Path(components: "c")])
        XCTAssertEqual(Set(rootChildren), rootExpected,
                       "Expected \(rootChildren) to have the same elements as \(rootExpected)")

        let aChildren = directoryStructure.childrenUnder(path: Path(components: "a"))
        let aExpected = Set([Path(components: "a", "b"), Path(components: "a", "c")])
        XCTAssertEqual(Set(aChildren), aExpected,
                       "Expected \(aChildren) to have the same elements as \(aExpected)")

        let bChildren = directoryStructure.childrenUnder(path: Path(components: "b"))
        XCTAssertTrue(bChildren.isEmpty, "There should be no children under \"b\"")

        let cChildren = directoryStructure.childrenUnder(path: Path(components: "c"))
        XCTAssertTrue(cChildren.isEmpty, "There should be no children under \"c\"")

        let abChildren = directoryStructure.childrenUnder(path: Path(components: "a", "b"))
        let abExpected = Set([Path(components: "a", "b", "c")])
        XCTAssertEqual(Set(abChildren), abExpected,
                       "Expected \(abChildren) to have the same elements as \(abExpected)")
    }
}
