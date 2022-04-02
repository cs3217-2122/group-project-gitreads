//
//  HtmlNodeTypeSimplifier.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class HtmlNodeTypeSimplifier {
    static var reverseMap = generateReverseMap()
    static let map = [
        "tag": ["tag_name"],
        "tagError": ["erroneous_end_tag_name"],
        "constant": ["doctype"],
        "attribute": ["attribute_name"],
        "string": ["attribute_value"],
        "comment": ["comment"],
        "bracket": [
            "<",
            ">",
            "</"
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

    static func simplifyHtmlNodeType(node: ASTNode) -> String {
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
