//
//  TokenAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct TokenAction {
    var text: String
    var action: (File, Int, Int) -> Void

    init(text: String, action: @escaping (File, Int, Int) -> Void) {
        self.text = text
        self.action = action
    }
}
