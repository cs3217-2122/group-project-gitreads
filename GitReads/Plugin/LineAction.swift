//
//  PluginAction.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//
import SwiftUI

struct LineAction {
    var text: String?
    var action: (ScreenViewModel, CodeViewModel, Int) -> Void
    var pluginView: AnyView?

    init(text: String?,
         action: @escaping (ScreenViewModel, CodeViewModel, Int) -> Void,
         view: AnyView?) {
        self.text = text
        self.action = action
        self.pluginView = view
    }
}
