//
//  FileAction.swift
//  GitReads
//
//  Created by Liu Zimu on 19/4/22.
//

import SwiftUI

struct FileAction {
    var text: String?
    var action: (ScreenViewModel, CodeViewModel) -> Void
    var pluginView: AnyView?

    init(text: String?,
         action: @escaping (ScreenViewModel, CodeViewModel) -> Void,
         view: AnyView?) {
        self.text = text
        self.action = action
        self.pluginView = view
    }
}
