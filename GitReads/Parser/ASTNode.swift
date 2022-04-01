//
//  ASTNode.swift
//  GitReads
//
//  Created by Liu Zimu on 28/3/22.
//

import Foundation

struct ASTNode {
    let type: String
    let start: [Int]
    let end: [Int]
    var children: [ASTNode]

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

        var rootNode = ASTNode(type: nodeType,
                               start: nodeStart,
                               end: nodeEnd,
                               children: [])

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

            var node = ASTNode(type: nodeType,
                               start: nodeStart,
                               end: nodeEnd,
                               children: [])

            node.children = buildChildren(jsonTrees: childrenNodes,
                                          parentNode: node)
            children.append(node)
        }

        return children
    }
}
