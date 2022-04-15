//
//  CParser.swift
//  GitReads
//
//  Created by Liu Zimu on 5/4/22.
//

class CParser: FileParser {

    static func parse(fileString: String, includeDeclarations: Bool = true) async throws -> ParseOutput {
        let rootNode = try await getAstFromApi(fileString: fileString)

        let leafNodes = getLeafNodesFromAst(rootNode: rootNode)
        simplifyLeafNodes(nodes: leafNodes)

        let lines = TokenConverter.nodesToLines(fileString: fileString,
                                                nodes: leafNodes)

        var declarations = [Declaration]()
        if includeDeclarations {
            declarations = CDeclarationParser.getDeclarations(rootNode: rootNode,
                                                              fileString: fileString)
        }

        var scopes: [Scope] = []
        if let rootNode = rootNode {
            scopes = getScopes(root: rootNode)
        }

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: declarations,
                           scopes: scopes
        )
    }

    static func getAstFromApi(fileString: String) async throws -> ASTNode? {
        let jsonTree = try await WebApiClient.getAstJson(
            apiPath: Constants.webParserApiAstPath,
            fileString: fileString,
            language: Language.c
        )

        return ASTNode.buildAstFromJson(jsonTree: jsonTree)
    }

    static func simplifyLeafNodes(nodes: [ASTNode]) {
        for node in nodes {
            node.type = CNodeTypeSimplifier.simplifyCNodeType(node: node)
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

    static let scopeMatcher = MatchAnyOf {
        // struct definitions
        Match(type: .exact("struct_specifier"), key: "scope") {
            Match(type: .exact("field_declaration_list"), key: "body")
        }
        // function definitions
        Match(type: .exact("function_definition"), key: "scope") {
            Match(type: .exact("compound_statement"), key: "body")
        }
    }

    static func getScopes(root: ASTNode) -> [Scope] {
        let astQuerier = ASTQuerier(root: root)

        let query = Query(matcher: scopeMatcher) { result -> Scope in
            let scopeNode = result["scope"]!
            let bodyNode = result["body"]!

            return Scope(
                prefixStart: Scope.Index(line: scopeNode.start.line, char: scopeNode.start.char),
                prefixEnd: Scope.Index(line: bodyNode.start.line, char: bodyNode.start.char + 1),
                end: Scope.Index(line: scopeNode.end.line, char: scopeNode.end.char)
            )
        }

        return astQuerier.doQuery(query)
    }
}
