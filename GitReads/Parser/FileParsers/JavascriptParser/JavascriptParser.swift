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

        let scopes = getScopes(root: rootNode)

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: declarations,
                           scopes: scopes
        )
    }

    static func getDeclarations(rootNode: ASTNode?, fileString: String) -> [Declaration] {
        []
    }

    static func getAstLocally(fileString: String) async throws -> ASTNode {
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

    static let scopeMatcher = MatchAnyOf {
        // Function declarations
        Match(type: .contains("function_declaration"), key: "scope") {
            Match(type: .exact("statement_block"), key: "body")
        }
        // Function expressions
        Match(type: .oneOf(["function", "generator_function"]), key: "scope") {
            Match(type: .exact("statement_block"), key: "body")
        }
        // Arrow functions
        Match(type: .exact("arrow_function"), key: "scope") { _ in // match children positionally
            MatchAny()
            Match(type: .exact("=>"), key: "prefix")
            MatchOptional {
                Match(type: .exact("statement_block"), key: "body")
            }
        }
        // Class declarations
        Match(type: .exact("class_declaration"), key: "scope") {
            Match(type: .exact("class_body"), key: "body")
        }
        // Class/Object methods
        Match(type: .exact("method_definition"), key: "scope") {
            Match(type: .exact("statement_block"), key: "body")
        }
    }

    static func getScopes(root: ASTNode) -> [Scope] {
        let astQuerier = ASTQuerier(root: root)

        let query = Query(matcher: scopeMatcher) { result -> Scope in
            let scopeNode = result["scope"]!

            let prefixStart = Scope.Index(line: scopeNode.start.line, char: scopeNode.start.char)
            let end = Scope.Index(line: scopeNode.end.line, char: scopeNode.end.char)

            let bodyNode = result["body"]

            guard let bodyNode = bodyNode else {
                // if no body node, then there has to be a prefix node
                let prefixNode = result["prefix"]!
                return Scope(
                    prefixStart: prefixStart,
                    prefixEnd: Scope.Index(line: prefixNode.end.line, char: prefixNode.end.char),
                    end: end
                )
            }

            return Scope(
                prefixStart: prefixStart,
                prefixEnd: Scope.Index(line: bodyNode.start.line, char: bodyNode.start.char + 1),
                end: end
            )
        }

        return astQuerier.doQuery(query)
    }
}
