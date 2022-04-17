//
//  VisualStudioTheme.swift
//  GitReads

import SwiftUI

// swiftlint:disable cyclomatic_complexity
// Based on: https://github.com/PrismJS/prism-themes/blob/master/themes/prism-vs.css
struct VisualStudioTheme: Theme {
    let name = "Visual Studio"
    let base = Color(hex: 0x393A34)

    func colorFor(_ type: TokenType) -> Color {
        switch type {
        case .functionCall, .functionDeclaration, .specialFunctionDeclaration,
             .methodCall, .methodDeclaration,
             .variable, .type:
            return base
        case .tag, .tagError:
            return Color(hex: 0x9a050f)
        case .keyword:
            return Color(hex: 0x0000ff)
        case .string, .specialString:
            return Color(hex: 0xA31515)
        case .escape:
            return Color(hex: 0xA71519)
        case .property:
            return Color(hex: 0x2B91AF)
        case .attribute:
            return Color(hex: 0xff0000)
        case .number, .builtinConstant, .builtinVariable:
            return Color(hex: 0x36acaa)
        case .comment:
            return Color(hex: 0x008000)
        case .space, .tab:
            return .clear
        case .bracket, .delimiter, .label, .operator,
             .specialPunctuation, .injection, .otherType:
            return base
        }
    }
}
