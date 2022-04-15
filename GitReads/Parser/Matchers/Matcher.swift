//
//  Matcher.swift
//  GitReads

/// Protocol that abstracts the logic of certain conditions that match an `ASTNode`
protocol Matcher {
    func match(node: ASTNode) -> MatchResult
}

/// Matcher that matches any node.
struct MatchAny: Matcher {
    let key: String?

    init(key: String? = nil) {
        self.key = key
    }

    func match(node: ASTNode) -> MatchResult {
        guard let key = key else {
            return .emptyResultMatch
        }

        return .matchFor(key: key, node: node)
    }
}
