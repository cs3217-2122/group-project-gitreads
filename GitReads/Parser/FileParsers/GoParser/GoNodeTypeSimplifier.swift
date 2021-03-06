//
//  GoTokenMap.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class GoNodeTypeSimplifier {
    static var reverseMap = generateReverseMap()
    static let map = [
        "type": ["type_identifier"],
        "property": ["field_identifier"],
        "variable": ["identifier"],
        "operator": [
            "--",
            "-",
            "-=",
            ":=",
            "!",
            "!=",
            "...",
            "*",
            "*",
            "*=",
            "/",
            "/=",
            "&",
            "&&",
            "&=",
            "%",
            "%=",
            "^",
            "^=",
            "+",
            "++",
            "+=",
            "<-",
            "<",
            "<<",
            "<<=",
            "<=",
            "=",
            "==",
            ">",
            ">=",
            ">>",
            ">>=",
            "|",
            "|=",
            "||",
            "~"
        ],
        "keyword": [
            "break",
            "case",
            "chan",
            "const",
            "continue",
            "default",
            "defer",
            "else",
            "fallthrough",
            "for",
            "func",
            "go",
            "goto",
            "if",
            "import",
            "interface",
            "map",
            "package",
            "range",
            "return",
            "select",
            "struct",
            "switch",
            "type",
            "var"
        ],
        "string": [
            "interpreted_string_literal",
            "raw_string_literal",
            "rune_literal"
        ],
        "escape": [
            "escape_sequence"
        ],
        "number": [
            "int_literal",
            "float_literal",
            "imaginary_literal"
        ],
        "builtinConstant": [
            "true",
            "false",
            "nil",
            "iota"
        ],
        "comment": [
            "comment"
        ]
    ]

    static func generateReverseMap() -> [String: String] {
        var reverseMap = [String: String]()
        for (simplifiedType, originalTypes) in map {
            for originalType in originalTypes {
                reverseMap[originalType] = simplifiedType
            }
        }
        return reverseMap
    }

    static func simplifyGoNodeType(node: ASTNode) -> String {
        guard let parent = node.parent else {
            return reverseMap[node.type] ?? "otherType"
        }

        // Function and method calls

        if node.type == "identifier" && parent.type == "call_expression" {
            return "functionCall"
        }

        if node.type == "field_identifier" && parent.type == "selector_expression"
                && parent.parent?.type ?? "" == "call_expression" {
            return "methodCall"
        }

        // Function and method declarations

        if node.type == "identifier" && parent.type == "function_declaration" {
            return "functionDeclaration"
        }

        if node.type == "field_identifier" && parent.type == "method_declaration" {
            return "methodDeclaration"
        }

        return reverseMap[node.type] ?? "otherType"
    }
}
