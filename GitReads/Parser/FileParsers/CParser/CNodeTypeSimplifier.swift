//
//  CNodeTypeSimplifier.swift
//  GitReads
//
//  Created by Liu Zimu on 5/4/22.
//

class CNodeTypeSimplifier {
    static var reverseMap = generateReverseMap()
    static let map = [
        "variable": ["identifier"],
        "constant": [
            "null"
        ],
        "property": ["field_identifier"],
        "label": ["statement_identifier"],
        "type": [
            "type_identifier",
            "primitive_type",
            "sized_type_specifier"
        ],
        "string": [
            "string_literal",
            "system_lib_string"
        ],
        "number": [
            "number_literal",
            "char_literal"
        ],
        "comment": [
            "comment"
        ],
        "delimiter": [
            ".",
            ";"
        ],
        "operator": [
            "--",
            "-",
            "-=",
            "->",
            "=",
            "!=",
            "*",
            "&",
            "&&",
            "+",
            "++",
            "+=",
            "<",
            "==",
            ">",
            "||"
        ],
        "keyword": [
            "preproc_directive",
            "break",
            "case",
            "const",
            "continue",
            "default",
            "do",
            "else",
            "enum",
            "extern",
            "for",
            "if",
            "inline",
            "return",
            "sizeof",
            "static",
            "struct",
            "switch",
            "typedef",
            "union",
            "volatile",
            "while",
            "#define",
            "#elif",
            "#else",
            "#endif",
            "#if",
            "#ifdef",
            "#ifndef",
            "#include"
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

    static func simplifyCNodeType(node: ASTNode) -> String {
        guard let parent = node.parent else {
            return reverseMap[node.type] ?? "otherType"
        }

        // Function and method calls

        if node.type == "identifier" && parent.type == "call_expression" {
            return "functionCall"
        }

        if node.type == "field_identifier" && parent.type == "field_expression"
                && parent.parent?.type ?? "" == "call_expression" {
            return "functionCall"
        }

        // Function and method declarations

        if node.type == "identifier" && parent.type == "function_declarator" {
            return "functionDeclaration"
        }

        if node.type == "identifier" && parent.type == "preproc_function_def" {
            return "specialFunctionDeclaration"
        }

        return reverseMap[node.type] ?? "otherType"
    }
}
