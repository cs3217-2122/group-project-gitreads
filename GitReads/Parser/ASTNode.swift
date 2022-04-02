//
//  ASTNode.swift
//  GitReads
//
//  Created by Liu Zimu on 28/3/22.
//

import Foundation

class ASTNode {
    var type: String
    let start: [Int]
    let end: [Int]
    var children: [ASTNode]
    weak var parent: ASTNode?

    init(type: String, start: [Int], end: [Int], children: [ASTNode], parent: ASTNode?) {
        self.type = type
        self.start = start
        self.end = end
        self.children = children
        self.parent = parent
    }

    static func buildSyntaxTree(jsonTree: Any?) -> ASTNode? {
        guard let jsonTree = jsonTree as? [String: Any] else {
            return nil
        }

        guard let nodeType = jsonTree["type"] as? String,
              let nodeStart = jsonTree["start"] as? [Int],
              let nodeEnd = jsonTree["end"] as? [Int],
              let children = jsonTree["children"] as? [Any]
        else {
            return nil
        }

        let rootNode = ASTNode(type: nodeType,
                               start: nodeStart,
                               end: nodeEnd,
                               children: [],
                               parent: nil
        )

        rootNode.children = buildChildren(jsonTrees: children,
                                          parentNode: rootNode)
        return rootNode
    }

    static func buildChildren(jsonTrees: [Any], parentNode: ASTNode) -> [ASTNode] {
        var children = [ASTNode]()
        for jsonTree in jsonTrees {
            guard let jsonTree = jsonTree as? [String: Any] else {
                break
            }

            guard let nodeType = jsonTree["type"] as? String,
                  let nodeStart = jsonTree["start"] as? [Int],
                  let nodeEnd = jsonTree["end"] as? [Int],
                  let childrenNodes = jsonTree["children"] as? [Any]
            else {
                break
            }

            let node = ASTNode(type: nodeType,
                               start: nodeStart,
                               end: nodeEnd,
                               children: [],
                               parent: parentNode
            )

            node.children = buildChildren(jsonTrees: childrenNodes,
                                          parentNode: node)
            children.append(node)
        }

        return children
    }
}
