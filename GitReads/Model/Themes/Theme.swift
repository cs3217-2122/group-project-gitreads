//
//  Theme.swift
//  GitReads

import SwiftUI

protocol Theme {
    var name: String { get }
    func colorFor(_ type: TokenType) -> Color
}

let themes: [String: Theme] = [
    OneLightTheme().name: OneLightTheme(),
    VisualStudioTheme().name: VisualStudioTheme()
]
