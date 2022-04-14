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

        let scopes = getScopes(root: rootNode)

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: [], // no declarations in HTML
                           scopes: scopes
        )
    }

    static func getAstLocally(fileString: String) async throws -> ASTNode {
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

    static let scopeMatcher = Match(type: .exact("element"), key: "element") {
        Match(type: .exact("start_tag"), key: "start")
        Match(type: .exact("end_tag"))
    }

    static func getScopes(root: ASTNode) -> [Scope] {
        let astQuerier = ASTQuerier(root: root)

        let query = Query(matcher: scopeMatcher) { result -> Scope in
            let elementNode = result["element"]!
            let startNode = result["start"]!
            return Scope(
                prefixStart: Scope.Index(line: elementNode.start.line, char: elementNode.start.char),
                prefixEnd: Scope.Index(line: startNode.end.line, char: startNode.end.char),
                end: Scope.Index(line: elementNode.end.line, char: elementNode.end.char)
            )
        }

        return astQuerier.doQuery(query)
    }
}
