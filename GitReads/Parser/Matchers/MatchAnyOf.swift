//
//  MatchAnyOf.swift
//  GitReads

/// `MatchAnyOf` accepts an array of matchers.
/// It matches any node if any of its matchers match that node.
struct MatchAnyOf: Matcher {
    let matchers: [Matcher]

    init(@MatcherBuilder matchers: () -> [Matcher]) {
        self.matchers = matchers()
    }

    func match(node: ASTNode) -> MatchResult {
        for matcher in matchers {
            let matchResult = matcher.match(node: node)
            if case .match = matchResult {
                return matchResult
            }
        }

        return .noMatch
    }
}
