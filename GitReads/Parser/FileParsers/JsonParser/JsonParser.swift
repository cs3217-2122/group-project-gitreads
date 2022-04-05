//
//  JsonParser.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class JsonParser: FileParser {

    static func parse(fileString: String) async throws -> [Line] {
        let rootNode = try await getAstLocally(fileString: fileString)
        let leafNodes = getLeafNodesFromAst(rootNode: rootNode)
        simplifyLeafNodes(nodes: leafNodes)

        return TokenConverter.nodesToLines(fileString: fileString,
                                           nodes: leafNodes)
    }

    static func getAstLocally(fileString: String) async throws -> ASTNode? {
        let stsTree = try LocalClient.getSTSTree(fileString: fileString, language: Language.json)

        return ASTNode.buildAstFromSTSTree(tree: stsTree)
    }

    static func simplifyLeafNodes(nodes: [ASTNode]) {
        for node in nodes {
            node.type = JsonNodeTypeSimplifier.simplifyJsonNodeType(node: node)
        }
    }

    static func getLeafNodesFromAst(rootNode: ASTNode?) -> [ASTNode] {
        guard let rootNode = rootNode else {
            return []
        }

        return dfs(node: rootNode)
    }

    static func dfs(node: ASTNode) -> [ASTNode] {
        if node.type == "pair" {
            var nodes = [ASTNode]()
            let key = node.children[0]
            let colon = node.children[1]
            let value = node.children[2]

            nodes.append(ASTNode(type: "keyword",
                                 start: key.start,
                                 end: key.end,
                                 children: [],
                                 parent: node))

            nodes.append(ASTNode(type: ":",
                                 start: colon.start,
                                 end: colon.end,
                                 children: [],
                                 parent: node))

            nodes += dfs(node: value)

            return nodes
        }

        // exception: string literal is considered leaf node
        if node.children.isEmpty || node.children[0].type == "\"" {
            return [ASTNode(type: node.type,
                            start: node.start,
                            end: node.end,
                            children: [],
                            parent: node.parent)]
        }

        // for internal node, continue dfs
        var nodes = [ASTNode]()
        for childNode in node.children {
            nodes += dfs(node: childNode)
        }

        return nodes
    }

}
