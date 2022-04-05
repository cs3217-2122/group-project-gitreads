//
//  JavascriptParser.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class JavascriptParser: FileParser {

    static func parse(fileString: String, includeDeclarations: Bool = true) async throws -> ParseOutput {
        let rootNode = try await getAstLocally(fileString: fileString)
        let leafNodes = getLeafNodesFromAst(rootNode: rootNode)
        simplifyLeafNodes(nodes: leafNodes)

        let lines = TokenConverter.nodesToLines(fileString: fileString,
                                                nodes: leafNodes)

        var declarations = [Declaration]()
        if includeDeclarations {
            declarations = getDeclarations(rootNode: rootNode, fileString: fileString)
        }

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: declarations)
    }

    static func getDeclarations(rootNode: ASTNode?, fileString: String) -> [Declaration] {
        []
    }

    static func getAstLocally(fileString: String) async throws -> ASTNode? {
        let stsTree = try LocalClient.getSTSTree(fileString: fileString, language: Language.javascript)

        return ASTNode.buildAstFromSTSTree(tree: stsTree)
    }

    static func simplifyLeafNodes(nodes: [ASTNode]) {
        for node in nodes {
            node.type = JavascriptNodeTypeSimplifier.simplifyJavascriptNodeType(node: node)
        }
    }

    static func getLeafNodesFromAst(rootNode: ASTNode?) -> [ASTNode] {
        guard let rootNode = rootNode else {
            return []
        }

        return dfs(node: rootNode)
    }

    static func dfs(node: ASTNode) -> [ASTNode] {
        // for leaf node, return the node
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
