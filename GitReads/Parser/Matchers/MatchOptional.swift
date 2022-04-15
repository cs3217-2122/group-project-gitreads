//
//  MatchOptional.swift
//  GitReads

struct MatchOptional: Matcher {
    let matcher: Matcher

    init(matcher: () -> Matcher) {
        self.matcher = matcher()
    }

    func match(node: ASTNode) -> MatchResult {
        let result = matcher.match(node: node)
        if case .noMatch = result {
            return .emptyResultMatch
        }

        return result
    }
}
