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
let TEST_MOCK_REPO = Repo(
    root: Directory(
        files: [
            File(path: Path(string: "/file1.txt"),
                 language: .others,
                 declarations: [],
                 lines: LazyDataSource(value: [])),
            File(path: Path(string: "/file2.txt"),
                 language: .others,
                 declarations: [],
                 lines: LazyDataSource(value: []))
        ],
        directories: [
            Directory(
                files: [
                    File(path: Path(string: "/dirA/fileA1.go"),
                         language: .go,
                         declarations: [],
                         lines: LazyDataSource(value: [])),
                    File(path: Path(string: "/dirA/fileA2.txt"),
                         language: .others,
                         declarations: [],
                         lines: LazyDataSource(value: []))
                ],
                directories: [],
                path: Path(string: "/dirA")),
            Directory(
                files: [
                    File(path: Path(string: "/dirB/fileB1.txt"),
                         language: .others,
                         declarations: [],
                         lines: LazyDataSource(value: []))
                ],
                directories: [
                    Directory(
                        files: [
                            File(path: Path(string: "/dirB/dirC/fileC1.go"),
                                 language: .go,
                                 declarations: [],
                                 lines: LazyDataSource(value: [])),
                            File(path: Path(string: "/dirB/dirC/fileC2.txt"),
                                 language: .others,
                                 declarations: [],
                                 lines: LazyDataSource(value: [])),
                            File(path: Path(string: "/dirB/dirC/fileC3.txt"),
                                 language: .others,
                                 declarations: [],
                                 lines: LazyDataSource(value: []))
                        ],
                        directories: [],
                        path: Path(string: "/dirB/dirC"))
                ],
                path: Path(string: "/dirB"))
        ],
        path: .root)
)
