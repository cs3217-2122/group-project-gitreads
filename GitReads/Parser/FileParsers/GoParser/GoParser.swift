//
//  GoParser.swift
//  GitReads
//
//  Created by Liu Zimu on 27/3/22.
//

class GoParser: FileParser {

    static func parse(fileString: String, includeDeclarations: Bool = true) async throws -> ParseOutput {
        let rootNode = try await getAstFromApi(fileString: fileString)

        let leafNodes = getLeafNodesFromAst(rootNode: rootNode)
        simplifyLeafNodes(nodes: leafNodes)

        let lines = TokenConverter.nodesToLines(fileString: fileString,
                                                nodes: leafNodes)

        var declarations = [Declaration]()
        if includeDeclarations {
            declarations = GoDeclarationParser.getDeclarations(rootNode: rootNode, fileString: fileString)
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
            language: Language.go
        )

        return ASTNode.buildAstFromJson(jsonTree: jsonTree)
    }

    static func simplifyLeafNodes(nodes: [ASTNode]) {
        for node in nodes {
            node.type = GoNodeTypeSimplifier.simplifyGoNodeType(node: node)
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
        // functions/methods
        Match(type: .oneOf(["function_declaration", "method_declaration"]), key: "scope") {
            Match(type: .exact("block"), key: "block")
        }
        // interfaces/structs in type declarations
        Match(type: .exact("type_declaration"), key: "scope") {
            Match(type: .exact("type_spec")) {
                MatchAnyOf {
                    Match(type: .exact("struct_type")) {
                        Match(type: .exact("field_declaration_list"), key: "block")
                    }
                    Match(type: .exact("interface_type")) {
                        Match(type: .exact("{"), key: "block")
                    }
                }
            }
        }
        // anonymous structs/interfaces
        NotMatch(type: .exact("type_spec")) {
            MatchAnyOf {
                Match(type: .exact("struct_type"), key: "scope") {
                    Match(type: .exact("field_declaration_list"), key: "block")
                }
                Match(type: .exact("interface_type"), key: "scope") {
                    Match(type: .exact("{"), key: "block")
                }
            }
        }
    }

    static func getScopes(root: ASTNode) -> [Scope] {
        let astQuerier = ASTQuerier(root: root)

        let query = Query(matcher: scopeMatcher) { result -> Scope in
            let scopeNode = result["scope"]!
            let blockNode = result["block"]!

            return Scope(
                prefixStart: Scope.Index(line: scopeNode.start.line, char: scopeNode.start.char),
                prefixEnd: Scope.Index(line: blockNode.start.line, char: blockNode.start.char + 1),
                end: Scope.Index(line: scopeNode.end.line, char: scopeNode.end.char)
            )
        }

        return astQuerier.doQuery(query)
    }
}
