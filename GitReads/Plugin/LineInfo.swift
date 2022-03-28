//
//  LineInfo.swift
//  GitReads
//
//  Created by Zhou Jiahao on 27/3/22.
//

struct LineInfo {
    var info: String
    var tokenInfo: [Int: String]

    init(info: String, tokenInfo: [Int: String]) {
        self.info = info
        self.tokenInfo = tokenInfo
    }

    func combineLineInfo(other: LineInfo) -> LineInfo {
        let newTokenInfo = self.tokenInfo.merging(other.tokenInfo) { x, y in x + "\n" + y }
        return LineInfo(info: self.info + "\n" + other.info, tokenInfo: newTokenInfo)
    }
}
