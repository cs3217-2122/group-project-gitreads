//
//  TokenAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct TokenAction {
    var text: String
    var action: (File, Int, Int) -> Void
    var takeInput: Bool

    init(text: String, action: @escaping (File, Int, Int) -> Void, takeInput: Bool) {
        self.text = text
        self.action = action
        self.takeInput = takeInput
    }
}
