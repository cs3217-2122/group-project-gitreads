//
//  Mock.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

let EMPTY_LINES = LazyDataSource(value: [Line]())

let MOCK_FILE = DummyFile.getFile()

let MOCK_DIRECTORY_A = Directory(
    files: [
        File(path: Path(components: "fileAasdfasdfasdfasdf"), language: .Java, declarations: [], lines: EMPTY_LINES)
    ],
    directories: [], path: Path(components: "directoryAasdfasdfasdfasdf"))
let MOCK_DIRECTORY_B = Directory(
    files: [File(path: Path(components: "fileB"), language: .Java, declarations: [], lines: EMPTY_LINES)],
    directories: [MOCK_DIRECTORY_A], path: Path(components: "directoryB"))

let MOCK_ROOT_DIRECTORY = Directory(
    files: [MOCK_FILE],
    directories: [MOCK_DIRECTORY_A, MOCK_DIRECTORY_B],
    path: .root)
