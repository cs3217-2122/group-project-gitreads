//
//  PluginAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

struct LineAction {
    var text: String?
    var action: (ScreenViewModel, CodeViewModel, Int, String) -> Void
    var takeInput: Bool

    init(text: String?, action: @escaping (ScreenViewModel, CodeViewModel, Int, String) -> Void, takeInput: Bool) {
        self.text = text
        self.action = action
        self.takeInput = takeInput
    }
}
