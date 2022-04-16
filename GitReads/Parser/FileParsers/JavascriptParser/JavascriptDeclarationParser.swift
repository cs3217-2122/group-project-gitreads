//
//  JavascriptDeclarationParser.swift
//  GitReads

import Foundation

// swiftlint:disable large_tuple
struct JavascriptDeclarationParser {
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

        let classDeclarationQuery = Query<ClassDeclaration>(matcher: classDeclarationMatcher) { results in
            let node = results["identifier"]!
            let (start, end, identifier) = nodeToStartEndAndIdentifier(node: node, lines: lines)
            return ClassDeclaration(start: start, end: end, identifier: identifier)
        }

        return astQuerier.doQuery(variableDeclarationQuery).flatMap { $0 }
        + astQuerier.doQuery(functionDeclarationQuery)
        + astQuerier.doQuery(classDeclarationQuery)
    }

    // defined as a function since object pattern matching is recursive
    static func objectPatternMatcher(depth: Int = 0) -> Matcher? {
        // limit the depth for performance, in practice a depth of more than 4 rarely ever occurs
        if depth > 4 {
            return nil
        }

        return Match(type: .exact("object_pattern")) { count in
            Match(type: .exact("{"))
            for _ in 2..<count {
                // more than one identifier may be matched, so we ensure that the key is unique,
                // then collect all the keys that start with "identifier"
                let identifierKey = "identifier-" + UUID().uuidString
                MatchAnyOf {
                    Match(type: .exact("shorthand_property_identifier_pattern"), key: identifierKey)
                    Match(type: .exact("rest_pattern")) {
                        Match(type: .exact("identifier"), key: identifierKey)
                    }
                    Match(type: .exact("object_assignment_pattern")) { _ in
                        MatchAnyOf {
                            Match(type: .exact("shorthand_property_identifier_pattern"), key: identifierKey)
                            arrayPatternMatcher(depth: depth + 1)
                            objectPatternMatcher(depth: depth + 1)
                        }
                    }
                    Match(type: .exact(","))
                }
            }
            Match(type: .exact("}"))
        }
    }

    // defined as a function since array pattern matching is recursive
    static func arrayPatternMatcher(depth: Int = 0) -> Matcher? {
        // limit the depth for performance, in practice a depth of more than 4 rarely ever occurs
        if depth > 4 {
            return nil
        }

        return Match(type: .exact("array_pattern")) { count in
            Match(type: .exact("["))
            for _ in 2..<count {
                // more than one identifier may be matched, so we ensure that the key is unique,
                // then collect all the keys that start with "identifier"
                let identifierKey = "identifier-" + UUID().uuidString
                MatchAnyOf {
                    Match(type: .exact("identifier"), key: identifierKey)
                    Match(type: .exact("rest_pattern")) {
                        Match(type: .exact("identifier"), key: identifierKey)
                    }
                    Match(type: .exact("assignment_pattern")) { _ in
                        MatchAnyOf {
                            Match(type: .exact("identifier"), key: identifierKey)
                            objectPatternMatcher(depth: depth + 1)
                            arrayPatternMatcher(depth: depth + 1)
                        }
                    }
                    Match(type: .exact(","))
                }
            }
            Match(type: .exact("]"))
        }
    }

    static let variableDeclarationMatcher = MatchAnyOf {
        Match(type: .exact("variable_declarator")) {
            MatchAnyOf {
                Match(type: .exact("identifier"), key: "identifier")
                objectPatternMatcher()
                arrayPatternMatcher()
            }
        }
        Match(type: .exact("formal_parameters")) { count in
            Match(type: .exact("("))
            for _ in 2..<count {
                // more than one identifier may be matched, so we ensure that the key is unique,
                // then collect all the keys that start with "identifier"
                let identifierKey = "identifier-" + UUID().uuidString
                MatchAnyOf {
                    Match(type: .exact("identifier"), key: identifierKey)
                    Match(type: .exact("rest_pattern")) {
                        Match(type: .exact("identifier"), key: identifierKey)
                    }
                    Match(type: .exact("assignment_pattern")) { _ in
                        MatchAnyOf {
                            Match(type: .exact("identifier"), key: identifierKey)
                            objectPatternMatcher()
                            arrayPatternMatcher()
                        }
                    }
                    objectPatternMatcher()
                    arrayPatternMatcher()
                    Match(type: .exact(","))
                }
            }
            Match(type: .exact(")"))
        }
        Match(type: .contains("field_definition")) {
            Match(type: .exact("property_identifier"), key: "identifier")
        }
        Match(type: .exact("object")) {
            Match(type: .exact("pair")) {
                Match(type: .exact("property_identifier"), key: "identifier")
            }
        }
    }

    static let functionDeclarationMatcher = MatchAnyOf {
        Match(type: .contains("function_declaration")) {
            Match(type: .exact("identifier"), key: "identifier")
        }
        Match(type: .contains("method_definition")) {
            Match(type: .exact("property_identifier"), key: "identifier")
        }
    }

    static let classDeclarationMatcher = Match(type: .contains("class_declaration")) {
        Match(type: .exact("identifier"), key: "identifier")
    }
}
