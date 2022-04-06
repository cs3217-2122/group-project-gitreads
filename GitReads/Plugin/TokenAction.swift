//
//  TokenAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct TokenAction {
    var text: String?
    var action: (ScreenViewModel, CodeViewModel, Int, Int, String) -> Void
    var takeInput: Bool

    init(text: String?, action: @escaping (ScreenViewModel, CodeViewModel, Int, Int, String) -> Void, takeInput: Bool) {
        self.text = text
        self.action = action
        self.takeInput = takeInput
    }
}
