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
            declarations = getDeclarations(rootNode: rootNode, fileString: fileString)
        }

        return ParseOutput(fileContents: fileString,
                           lines: lines,
                           declarations: declarations)
    }

    static func getDeclarations(rootNode: ASTNode?, fileString: String) -> [Declaration] {
        guard let rootNode = rootNode else {
            return []
        }

        let lines = TokenConverter.breakStringByline(fileString)
        return getFunctionDeclarations(node: rootNode, lines: lines)
        + getStructDeclarations(node: rootNode, lines: lines)
    }

    static func getFunctionDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        guard !node.children.isEmpty else {
            return []
        }

        guard node.type == "function_definition" else {
            var declarations = [Declaration]()
            for child in node.children {
                declarations += getFunctionDeclarations(node: child, lines: lines)
            }

            return declarations
        }

        var identifier = ""
        for child in node.children where child.type == "function_declarator" {
            for grandChild in child.children where grandChild.type == "identifier" {
                identifier = String(TokenConverter.getTokenString(lines: lines,
                                                                  start: grandChild.start,
                                                                  end: grandChild.end)[0])
            }
        }

        return [
            FunctionDeclaration(start: node.start,
                                end: node.end,
                                identifier: identifier)
        ]
    }

    static func getStructDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        guard !node.children.isEmpty else {
            return []
        }

        guard node.type == "struct_specifier" else {
            var declarations = [Declaration]()
            for child in node.children {
                declarations += getStructDeclarations(node: child, lines: lines)
            }

            return declarations
        }

        var identifier = ""
        for child in node.children where child.type == "type_identifier" {
            identifier = String(TokenConverter.getTokenString(lines: lines,
                                                              start: child.start,
                                                              end: child.end)[0])
        }

        return [
            StructDeclaration(start: node.start,
                              end: node.end,
                              identifier: identifier)
        ]
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

}
