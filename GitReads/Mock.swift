//
//  Mock.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

let EMPTY_LINES = LazyDataSource(value: [Line]())

let EMPTY_PARSE_OUTPUT = LazyDataSource(value: ParseOutput(fileContents: "",
                                                           lines: [],
                                                           declarations: [],
                                                           scopes: []
                                                          ))

let MOCK_FILE = DummyFile.getFile()

let MOCK_DIRECTORY_A = Directory(
    files: [
        File(
            path: Path(components: "fileAasdfasdfasdfasdf"),
            sha: "deadbeef",
            language: .others,
            parseOutput: EMPTY_PARSE_OUTPUT)
    ],
    directories: [], path: Path(
        components: "directoryAasdfasdfasdfasdf.directoryAasdfasdfasdfasdf.directoryAasdfasdfasdfasdf"))
let MOCK_DIRECTORY_B = Directory(
    files: [File(
        path: Path(components: "fileB"),
        sha: "deadbeef",
        language: .others,
        parseOutput: EMPTY_PARSE_OUTPUT
    )],
    directories: [MOCK_DIRECTORY_A],
    path: Path(components: "directoryB")
)

let MOCK_ROOT_DIRECTORY = Directory(
    files: [MOCK_FILE],
    directories: [MOCK_DIRECTORY_A, MOCK_DIRECTORY_B],
    path: .root)
