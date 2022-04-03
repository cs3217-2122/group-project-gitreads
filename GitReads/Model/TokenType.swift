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
    case type
    case property
    case variable
    case `operator`
    case keyword
    case string
    case escape
    case number
    case constant
    case tag
    case tagError
    case bracket
    case attribute
    case comment
    case injection
    case space
    case tab
    case otherType
}
