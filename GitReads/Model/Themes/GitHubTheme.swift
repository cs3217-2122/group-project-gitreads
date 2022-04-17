//
//  GitHubTheme.swift
//  GitReads

import SwiftUI

// Based on: https://github.com/PrismJS/prism-themes/blob/master/themes/prism-ghcolors.css
struct GitHubTheme: Theme {
    let name = "GitHub"
    let base = Color(hex: 0x393A34)

    func colorFor(_ type: TokenType) -> Color {
        switch type {
        case .functionCall, .functionDeclaration, .specialFunctionDeclaration,
             .methodCall, .methodDeclaration,
             .type:
            return Color(hex: 0x9a050f)
        case .tag, .tagError:
            return Color(hex: 0x00009f)
        case .keyword:
            return Color(hex: 0x00a4db)
        case .string, .specialString:
            return Color(hex: 0xe3116c)
        case .escape:
            return Color(hex: 0xe8166d)
        case .attribute, .property, .number, .builtinConstant, .builtinVariable:
            return Color(hex: 0x36acaa)
        case .comment:
            return Color(hex: 0x999988)
        case .space, .tab:
            return .clear
        case .operator, .variable:
            return base
        case .bracket, .delimiter, .label, .specialPunctuation, .injection, .otherType:
            return base
        }
    }
}
