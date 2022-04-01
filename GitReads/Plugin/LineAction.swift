//
//  PluginAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

struct LineAction {
    var text: String?
    var action: (File, Int, String) -> Void
    var takeInput: Bool

    init(text: String?, action: @escaping (File, Int, String) -> Void, takeInput: Bool) {
        self.text = text
        self.action = action
        self.takeInput = takeInput
    }
}
