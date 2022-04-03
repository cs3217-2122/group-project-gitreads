//
//  JsonNodeTypeSimplifier.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class JsonNodeTypeSimplifier {
    static var reverseMap = generateReverseMap()
    static let map = [
        "keyword": ["keyword"],
        "string": ["string"],
        "escape": [
            "{",
            "}"
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

    static func simplifyJsonNodeType(node: ASTNode) -> String {
        guard let parent = node.parent else {
            return reverseMap[node.type] ?? "otherType"
        }

        if node.type == "raw_text"
            && (parent.type == "script_element" || parent.type == "style_element") {
            return "injection"
        }

        return reverseMap[node.type] ?? "otherType"
    }
}
