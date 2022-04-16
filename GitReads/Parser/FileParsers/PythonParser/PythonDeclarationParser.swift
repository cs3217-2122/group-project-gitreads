//
//  PythonDeclarationParser.swift
//  GitReads
//

import Foundation
import Cache

// swiftlint:disable large_tuple
struct PythonDeclarationParser {
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

    static func identifierMatcher(key: String = "identifier") -> Matcher {
        Match(type: .exact("identifier"), key: key)
    }

    static func listSplatPatternMatcher(key: String = "identifier") -> Matcher {
        Match(type: .exact("list_splat_pattern")) {
            identifierMatcher(key: key)
        }
    }

    static func dictionarySplatPatternMatcher(key: String = "identifier") -> Matcher {
        Match(type: .exact("dictionary_splat_pattern")) {
            identifierMatcher(key: key)
        }
    }

    static func tuplePatternMatcher(depth: Int = 0) -> Matcher? {
        if depth > 4 {
            return nil
        }

        return Match(type: .exact("tuple_pattern")) { count in
            Match(type: .exact("("))
            for _ in 2..<count {
                let key = "identifier-" + UUID().uuidString

                MatchAnyOf {
                    identifierMatcher(key: key)
                    listSplatPatternMatcher(key: key)
                    tuplePatternMatcher(depth: depth + 1)
                    listPatternMatcher(depth: depth + 1)
                    Match(type: .exact(","))
                }
            }
            Match(type: .exact(")"))
        }
    }

    static func listPatternMatcher(depth: Int = 0) -> Matcher? {
        if depth > 4 {
            return nil
        }

        return Match(type: .exact("list_pattern")) { count in
            Match(type: .exact("["))
            for _ in 2..<count {
                let key = "identifier-" + UUID().uuidString

                MatchAnyOf {
                    identifierMatcher(key: key)
                    listSplatPatternMatcher(key: key)
                    tuplePatternMatcher(depth: depth + 1)
                    listPatternMatcher(depth: depth + 1)
                    Match(type: .exact(","))
                }
            }
            Match(type: .exact("]"))
        }

    }

    static func patternMatcher(key: String = "identifier") -> Matcher {
        MatchAnyOf {
            identifierMatcher(key: key)
            listSplatPatternMatcher(key: key)
            tuplePatternMatcher()
            listPatternMatcher()
        }
    }

    static let assignmentMatcher = Match(type: .exact("assignment")) { _ in
        MatchAnyOf {
            patternMatcher(key: "identifier")
            Match(type: .exact("pattern_list")) { count in
                for _ in 1...count {
                    let key = "identifier-" + UUID().uuidString
                    MatchAnyOf {
                        patternMatcher(key: key)
                        Match(type: .exact(","))
                    }
                }
            }
        }
    }

    static func defaultParameterMatcher(key: String = "identifier") -> Matcher {
        Match(type: .contains("default_parameter")) { _ in
            identifierMatcher(key: key)
        }
    }

    static func typedParameterMatcher(key: String = "identifier") -> Matcher {
        Match(type: .exact("typed_parameter")) {
            identifierMatcher(key: key)
        }
    }

    static let parametersMatcher = Match(type: .oneOf(["parameters", "lambda_parameters"])) { count in
        Match(type: .exact("("))
        for _ in 2..<count {
            let key = "identifier-" + UUID().uuidString

            MatchAnyOf {
                identifierMatcher(key: key)
                defaultParameterMatcher(key: key)
                typedParameterMatcher(key: key)
                listSplatPatternMatcher(key: key)
                dictionarySplatPatternMatcher(key: key)
                tuplePatternMatcher()
                Match(type: .exact(","))
            }
        }
        Match(type: .exact(")"))
    }

    static let variableDeclarationMatcher = MatchAnyOf {
        assignmentMatcher
        parametersMatcher
    }

    static let functionDeclarationMatcher = Match(type: .contains("function_definition")) {
        Match(type: .exact("identifier"), key: "identifier")
    }

    static let classDeclarationMatcher = Match(type: .contains("class_definition")) {
        Match(type: .exact("identifier"), key: "identifier")
    }
}
