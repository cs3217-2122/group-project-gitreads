//
//  GoDeclarationParser.swift
//  GitReads

import Foundation

// swiftlint:disable large_tuple
struct GoDeclarationParser {
    static func nodeToStartEndAndIdentifier(
        node: MatchResult.Node,
        lines: [String.UTF8View]
    ) -> (start: [Int], end: [Int], identifier: String) {
        let start = [node.start.line, node.start.char]
        let end = [node.end.line, node.end.char]

        let identifier = String(
            TokenConverter.getTokenString(
                lines: lines,
                start: start,
                end: end
            )[0]
        )

        return (start, end, identifier)
    }

    static func getDeclarations(rootNode: ASTNode?, fileString: String) -> [Declaration] {
        guard let rootNode = rootNode else {
            return []
        }

        let lines = TokenConverter.breakStringByline(fileString)
        let astQuerier = ASTQuerier(root: rootNode)

        let variableDeclarationQuery = Query(matcher: variableDeclarationMatcher) { results in
            Array(
                results.filter { key, _ in
                    key.hasPrefix("identifier")
                }.mapValues { node -> VariableDeclaration in
                    let (start, end, identifier) = nodeToStartEndAndIdentifier(node: node, lines: lines)
                    return VariableDeclaration(start: start, end: end, identifier: identifier)
                }.values
            )
        }

        let functionDeclarationQuery = Query<FunctionDeclaration>(matcher: functionDeclarationMatcher) { results in
            let node = results["identifier"]!
            let (start, end, identifier) = nodeToStartEndAndIdentifier(node: node, lines: lines)
            return FunctionDeclaration(start: start, end: end, identifier: identifier)
        }

        let typeDeclarationQuery = Query<TypeDeclaration>(matcher: typeDeclarationMatcher) { results in
            let node = results["identifier"]!
            let (start, end, identifier) = nodeToStartEndAndIdentifier(node: node, lines: lines)
            return TypeDeclaration(start: start, end: end, identifier: identifier)
        }

        return astQuerier.doQuery(variableDeclarationQuery).flatMap { $0 }
        + astQuerier.doQuery(functionDeclarationQuery)
        + astQuerier.doQuery(typeDeclarationQuery)
    }

    static func matchAllIdentifiers(count: Int) -> [Matcher] {
        Array(1...count).map { _ in
            let key = "identifier-" + UUID().uuidString
            return MatchOptional {
                Match(type: .exact("identifier"), key: key)
            }
        }
    }

    static let variableDeclarationMatcher = MatchAnyOf {
        Match(type: .exact("short_var_declaration")) { _ in
            Match(type: .exact("expression_list")) { count in
                matchAllIdentifiers(count: count)
            }
        }
        Match(type: .oneOf(["var_declaration", "const_declaration"])) { count in
            for _ in 1...count {
                MatchOptional {
                    Match(type: .oneOf(["var_spec", "const_spec"])) { count in
                        matchAllIdentifiers(count: count)
                    }
                }
            }
        }
        Match(type: .oneOf(["function_declaration", "method_declaration"])) { count in
            for _ in 1...count {
                MatchOptional {
                    Match(type: .exact("parameter_list")) { count in
                        for _ in 1...count {
                            MatchOptional {
                                Match(type: .exact("parameter_declaration")) { count in
                                    matchAllIdentifiers(count: count)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static let functionDeclarationMatcher = MatchAnyOf {
        Match(type: .contains("function_declaration")) {
            Match(type: .exact("identifier"), key: "identifier")
        }
        Match(type: .contains("method_declaration")) {
            Match(type: .exact("field_identifier"), key: "identifier")
        }
    }

    static let typeDeclarationMatcher = Match(type: .exact("type_declaration")) {
        MatchAnyOf {
            Match(type: .exact("type_spec")) {
                Match(type: .exact("type_identifier"), key: "identifier")
            }
            Match(type: .exact("type_alias")) { _ in
                Match(type: .exact("type_identifier"), key: "identifier")
            }
        }
    }
}
