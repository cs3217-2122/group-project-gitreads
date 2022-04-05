//
//  PythonNodeTypeSimplifier.swift
//  GitReads
//
//  Created by Liu Zimu on 5/4/22.
//

class PythonNodeTypeSimplifier {
    static var reverseMap = generateReverseMap()
    static let map = [
        "variable": ["identifier"],
        "functionCall": ["decorator"],
        "string": [
            "string"
        ],
        "escape": [
            "escape_sequence"
        ],
        "number": [
            "integer",
            "float"
        ],
        "builtinConstant": [
            "true",
            "false",
            "none"
        ],
        "comment": [
            "comment"
        ],
        "operator": [
            "-",
            "-=",
            "!=",
            "*",
            "**",
            "**=",
            "*=",
            "/",
            "//",
            "//=",
            "/=",
            "&",
            "%",
            "%=",
            "^",
            "+",
            "->",
            "+=",
            "<",
            "<<",
            "<=",
            "<>",
            "=",
            ":=",
            "==",
            ">",
            ">=",
            ">>",
            "|",
            "~",
            "and",
            "in",
            "is",
            "not",
            "or"
        ],
        "keyword": [
            "as",
            "assert",
            "async",
            "await",
            "break",
            "class",
            "continue",
            "def",
            "del",
            "elif",
            "else",
            "except",
            "exec",
            "finally",
            "for",
            "from",
            "global",
            "if",
            "import",
            "lambda",
            "nonlocal",
            "pass",
            "print",
            "raise",
            "return",
            "try",
            "while",
            "with",
            "yield",
            "match",
            "case"
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

    static func simplifyPythonNodeType(node: ASTNode) -> String {
        guard let parent = node.parent else {
            return reverseMap[node.type] ?? "otherType"
        }

        if node.type == "{" || node.type == "}" && parent.type == "interpolation" {
            return "specialPunctuation"
        }

        if node.type == "identifier" && parent.type == "attribute" {
            return "property"
        }

        if node.type == "identifier" && parent.type == "type" {
            return "type"
        }

        // Function and method calls

        if node.type == "identifier" && parent.type == "call" {
            return "functionCall"
        }

        if node.type == "identifier" && parent.type == "attribute"
                && parent.parent?.type ?? "" == "call" {
            return "methodCall"
        }

        // Function and method declarations

        if node.type == "identifier" && parent.type == "function_definition" {
            return "functionDeclaration"
        }

        return reverseMap[node.type] ?? "otherType"
    }
}
