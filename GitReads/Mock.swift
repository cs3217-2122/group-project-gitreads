//
//  Mock.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

let MOCK_FILE = DummyFile.getFile()

let MOCK_DIRECTORY_A = Directory(
    files: [File(name: "fileAasdfasdfasdfasdf", language: "", declarations: [], lines: [])],
    directories: [], name: "directoryAasdfasdfasdfasdf")
let MOCK_DIRECTORY_B = Directory(
    files: [File(name: "fileB", language: "", declarations: [], lines: [])],
    directories: [MOCK_DIRECTORY_A], name: "directoryB")

let MOCK_ROOT_DIRECTORY = Directory(
    files: [MOCK_FILE],
    directories: [MOCK_DIRECTORY_A, MOCK_DIRECTORY_B],
    name: "root")
