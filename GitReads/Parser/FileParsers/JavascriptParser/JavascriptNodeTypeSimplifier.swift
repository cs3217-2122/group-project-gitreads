//
//  JavascriptNodeTypeSimplifier.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class JavascriptNodeTypeSimplifier {
    static var reverseMap = generateReverseMap()
    static let map = [
        "variable": ["identifier"],
        "property": ["property_identifier"],
        "builtinVariable": [
            "this",
            "super"
        ],
        "builtinConstant": [
            "true",
            "false",
            "null",
            "undefined"
        ],
        "comment": ["comment"],
        "string": [
            "string",
            "template_string"
        ],
        "specialString": ["regex"],
        "number": ["number"],
        "escape": [
            "{",
            "}"
        ],
        "delimiter": [
            ";",
            "?.",
            ".",
            ","
        ],
        "bracket": [
            "(",
            ")",
            "[",
            "]",
            "{",
            "}"
        ],
        "operator": [
            "-",
            "--",
            "-=",
            "+",
            "++",
            "+=",
            "*",
            "*=",
            "**",
            "**=",
            "/",
            "/=",
            "%",
            "%=",
            "<",
            "<=",
            "<<",
            "<<=",
            "=",
            "==",
            "===",
            "!",
            "!=",
            "!==",
            "=>",
            ">",
            ">=",
            ">>",
            ">>=",
            ">>>",
            ">>>=",
            "~",
            "^",
            "&",
            "|",
            "^=",
            "&=",
            "|=",
            "&&",
            "||",
            "??",
            "&&=",
            "||=",
            "??="
        ],
        "keyword": [
            "as",
            "async",
            "await",
            "break",
            "case",
            "catch",
            "class",
            "const",
            "continue",
            "debugger",
            "default",
            "delete",
            "do",
            "else",
            "export",
            "extends",
            "finally",
            "for",
            "from",
            "function",
            "get",
            "if",
            "import",
            "in",
            "instanceof",
            "let",
            "new",
            "of",
            "return",
            "set",
            "static",
            "switch",
            "target",
            "throw",
            "try",
            "typeof",
            "var",
            "void",
            "while",
            "with",
            "yield"
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

    static func simplifyJavascriptNodeType(node: ASTNode) -> String {
        guard let parent = node.parent else {
            return reverseMap[node.type] ?? "otherType"
        }

        if node.type == "${" || node.type == "}" && parent.type == "template_substitution" {
            return "specialPunctuation"
        }

        if node.type == "identifier" {
            return simplifyIdentifier(node: node)
        }

        if node.type == "property_identifier" {
            return simplifyPropertyIdentifier(node: node)
        }

        return reverseMap[node.type] ?? "otherType"
    }

    private static func simplifyIdentifier(node: ASTNode) -> String {
        guard let parent = node.parent, node.type == "identifier" else {
            return reverseMap[node.type] ?? "otherType"
        }

        // Function and method calls

        if parent.type == "call_expression" {
            return "functionCall"
        }

        // Function and method declarations
        if parent.type == "function" {
            return "functionDeclaration"
        }

        if parent.type == "function_declaration" {
            return "functionDeclaration"
        }

        if parent.type == "variable_declarator"
            && parent.children.count == 2
            && (parent.children[1].type == "function"
                || parent.children[1].type == "arrow_function") {
            return "functionDeclaration"
        }

        if parent.type == "assignment_expression"
            && parent.children.count == 2
            && (parent.children[1].type == "function"
                || parent.children[1].type == "arrow_function") {
            return "functionDeclaration"
        }

        return reverseMap[node.type] ?? "otherType"
    }

    private static func simplifyPropertyIdentifier(node: ASTNode) -> String {
        guard let parent = node.parent, node.type == "property_identifier" else {
            return reverseMap[node.type] ?? "otherType"
        }

        // Function and method calls

        if parent.type == "member_expression" && parent.parent?.type == "call_expression" {
            return "methodCall"
        }

        // Function and method declarations
        if parent.type == "method_definition" {
            return "methodDeclaration"
        }

        if parent.type == "pair"
            && parent.children.count == 2
            && (parent.children[1].type == "function"
                || parent.children[1].type == "arrow_function") {
            return "methodDeclaration"
        }

        if parent.type == "member_expression"
            && parent.children.count == 2
            && parent.parent?.type == "assignment_expression"
            && (parent.parent?.children[1].type == "function"
                || parent.parent?.children[1].type == "arrow_function") {
            return "methodDeclaration"
        }

        return reverseMap[node.type] ?? "otherType"
    }
}
