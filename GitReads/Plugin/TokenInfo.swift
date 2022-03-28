//
//  TokenInfo.swift
//  GitReads
//
//  Created by Zhou Jiahao on 27/3/22.
//

struct TokenInfo {
    let info: String

    init(info: String) {
        self.info = info
    }

    func combineWith(other: TokenInfo) -> TokenInfo {
        TokenInfo(info: self.info + "\n" + other.info)
    }
}
