//
//  FileInfo.swift
//  GitReads
//
//  Created by Zhou Jiahao on 26/3/22.
//

struct FileInfo {
    var info: String
    var lineInfo: [Int: LineInfo]

    init(info: String, lineInfo: [Int: LineInfo]) {
        self.info = info
        self.lineInfo = lineInfo
    }

    func combineFileInfo(other: FileInfo) -> FileInfo {
        let newLineInfo = lineInfo.merging(other.lineInfo) { x, y in x.combineLineInfo(other: y) }
        return FileInfo(info: info + "\n" + other.info, lineInfo: newLineInfo)
    }
}
