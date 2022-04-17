//
//  OneLightTheme.swift
//  GitReads

import SwiftUI

// Based on: https://github.com/PrismJS/prism-themes/blob/master/themes/prism-one-light.css
struct OneLightTheme: Theme {
    let name = "One Light"
    let base = Color(hue: 230 / 360, saturation: 0.08, lightness: 0.24)

    func colorFor(_ type: TokenType) -> Color {
        switch type {
        case .functionCall, .functionDeclaration, .specialFunctionDeclaration,
             .methodCall, .methodDeclaration,
             .type:
            return Color(hue: 221 / 360, saturation: 0.87, lightness: 0.6)
        case .tag, .tagError:
            return Color(hue: 5 / 360, saturation: 0.74, lightness: 0.59)
        case .keyword:
            return Color(hue: 301 / 360, saturation: 0.63, lightness: 0.4)
        case .string, .specialString:
            return Color(hue: 119 / 360, saturation: 0.34, lightness: 0.47)
        case .escape:
            return Color(hue: 123 / 360, saturation: 0.34, lightness: 0.37)
        case .attribute, .property, .number, .builtinConstant, .builtinVariable:
            return Color(hue: 35 / 360, saturation: 0.99, lightness: 0.36)
        case .comment:
            return Color(hue: 230 / 360, saturation: 0.04, lightness: 0.64)
        case .space, .tab:
            return .clear
        case .variable, .operator:
            return base
        case .bracket, .delimiter, .label, .specialPunctuation, .injection, .otherType:
            return base
        }
    }
}
