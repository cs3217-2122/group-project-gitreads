//
//  TokenAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//
import SwiftUI

struct TokenAction {
    var text: String?
    var action: (ScreenViewModel, CodeViewModel, Int, Int) -> Void
    var pluginView: AnyView

    init(text: String?, action: @escaping (ScreenViewModel, CodeViewModel, Int, Int) -> Void,
         view: AnyView) {
        self.text = text
        self.action = action
        self.pluginView = view
    }
}
