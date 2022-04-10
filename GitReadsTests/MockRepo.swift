//
//  TestMocks.swift
//  GitReadsTests
//
//  Created by Tan Kang Liang on 23/3/22.
//

@testable import GitReads

/// dirA/
///    fileA1.go
///    fileA2.txt
/// dirB/
///    fileB1.txt
///    dirC/
///       fileC1.go
///       fileC2.txt
///       fileC3.txt
/// file1.txt
/// file2.txt
///

struct MockRepo {
    static let repo = Repo(
        name: "mock-repo",
        owner: "GitReads",
        description: "",
        platform: .github,
        defaultBranch: "main",
        branches: ["main"],
        currBranch: "main",
        root: root,
        htmlURL: nil)

    static let file1 = File(path: Path(string: "/file1.txt"),
                            sha: "deadbeef",
                            language: .others,
                            parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let file2 = File(path: Path(string: "/file2.txt"),
                            sha: "deadbeef",
                            language: .others,
                            parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let root = Directory(
        files: [file1, file2],
        directories: [dirA, dirB],
        path: .root
    )

    static let fileA1 = File(path: Path(string: "/dirA/fileA1.go"),
                             sha: "deadbeef",
                             language: .go,
                             parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let fileA2 = File(path: Path(string: "/dirA/fileA2.txt"),
                             sha: "deadbeef",
                             language: .others,
                             parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))
    static let dirA = Directory(
        files: [fileA1, fileA2],
        directories: [],
        path: Path(string: "/dirA"))

    static let fileB1 = File(path: Path(string: "/dirB/fileB1.txt"),
                             sha: "deadbeef",
                             language: .others,
                             parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let dirB = Directory(
        files: [fileB1],
        directories: [dirC],
        path: Path(string: "/dirB"))

    static let fileC1 = File(path: Path(string: "/dirB/dirC/fileC1.go"),
                             sha: "deadbeef",
                             language: .go,
                             parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let fileC2 = File(path: Path(string: "/dirB/dirC/fileC2.txt"),
                             sha: "deadbeef",
                             language: .others,
                             parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let fileC3 = File(path: Path(string: "/dirB/dirC/fileC3.txt"),
                             sha: "deadbeef",
                             language: .others,
                             parseOutput: LazyDataSource(
                                value: ParseOutput(fileContents: "", lines: [], declarations: [])))

    static let dirC = Directory(
        files: [fileC1, fileC2, fileC3],
        directories: [],
        path: Path(string: "/dirB/dirC"))
}
