//
//  HtmlParser.swift
//  GitReads
//
//  Created by Liu Zimu on 2/4/22.
//

class HtmlParser: FileParser {

    static func parse(fileString: String, includeDeclarations: Bool = true) async throws -> ParseOutput {
        let rootNode = try await getAstLocally(fileString: fileString)
        let leafNodes = getLeafNodesFromAst(rootNode: rootNode)
        simplifyLeafNodes(nodes: leafNodes)

        let lines = TokenConverter.nodesToLines(fileString: fileString,
                                                nodes: leafNodes)

        let declarations = [Declaration]()

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: declarations,
                           scopes: []
        )
    }

    static func getAstLocally(fileString: String) async throws -> ASTNode? {
        let stsTree = try LocalClient.getSTSTree(fileString: fileString, language: Language.html)

        return ASTNode.buildAstFromSTSTree(tree: stsTree)
    }

    static func simplifyLeafNodes(nodes: [ASTNode]) {
        for node in nodes {
            node.type = HtmlNodeTypeSimplifier.simplifyHtmlNodeType(node: node)
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
        // exception: doctype is considered leaf node
        if node.type == "doctype" {
            return [ASTNode(type: "otherType",
                            start: node.start,
                            end: node.end,
                            children: [],
                            parent: node.parent)]
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
