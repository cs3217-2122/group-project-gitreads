//
//  PluginAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

struct LineAction {
    var text: String
    var action: (File, Int) -> Void

    init(text: String, action: @escaping (File, Int) -> Void) {
        self.text = text
        self.action = action
    }
}
