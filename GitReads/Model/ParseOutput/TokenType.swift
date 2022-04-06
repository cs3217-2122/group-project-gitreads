//
//  TokenType.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import Foundation

enum TokenType: String, Codable {
    case functionCall
    case functionDeclaration
    case specialFunctionDeclaration
    case methodCall
    case methodDeclaration
    case type
    case property
    case variable
    case `operator`
    case keyword
    case string
    case specialString
    case escape
    case number
    case builtinConstant
    case builtinVariable
    case tag
    case tagError
    case bracket
    case delimiter
    case attribute
    case label
    case comment
    case injection
    case specialPunctuation
    case space
    case tab
    case otherType
}
