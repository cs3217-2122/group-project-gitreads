//
//  Mock.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

let EMPTY_LINES = LazyDataSource(value: [Line]())

let MOCK_FILE = DummyFile.getFile()

let MOCK_DIRECTORY_A = Directory(
    files: [File(name: "fileAasdfasdfasdfasdf", language: .Java, declarations: [], lines: EMPTY_LINES)],
    directories: [], name: "directoryAasdfasdfasdfasdf")
let MOCK_DIRECTORY_B = Directory(
    files: [File(name: "fileB", language: .Java, declarations: [], lines: EMPTY_LINES)],
    directories: [MOCK_DIRECTORY_A], name: "directoryB")

let MOCK_ROOT_DIRECTORY = Directory(
    files: [MOCK_FILE],
    directories: [MOCK_DIRECTORY_A, MOCK_DIRECTORY_B],
    name: "root")
