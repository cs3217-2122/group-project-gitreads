//
//  Theme.swift
//  GitReads

import SwiftUI

protocol Theme {
    var name: String { get }
    func colorFor(_ type: TokenType) -> Color
}

let themes: [String: Theme] = [
    OneLightTheme(),
    VisualStudioTheme(),
    GitHubTheme()
].reduce(into: [String: Theme]()) { (dict, theme: Theme) in
    dict[theme.name] = theme
}
