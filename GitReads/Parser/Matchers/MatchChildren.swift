//
//  MatchChildren.swift
//  GitReads

/// `MatchChildren` accepts an array of children matchers.
/// It matches a node if all of its children matchers have at least one unique match in the children
/// of that node.
struct MatchChildren: Matcher {
    let childrenMatchers: [Matcher]

    init(@MatcherBuilder children: () -> [Matcher]) {
        self.childrenMatchers = children()
    }

    func match(node: ASTNode) -> MatchResult {
        if childrenMatchers.isEmpty {
            return .emptyResultMatch
        }

        var match = MatchResult.emptyResultMatch
        var matchers = childrenMatchers

        for child in node.children {
            var matchedIdx: Int?

            for (idx, matcher) in matchers.enumerated() {
                let matchResult = matcher.match(node: child)
                if case .match = matchResult {
                    match = match.combine(matchResult)
                    matchedIdx = idx
                    break
                }
            }

            if let matchedIdx = matchedIdx {
                matchers.remove(at: matchedIdx)
            }
        }

        return matchers.isEmpty ? match : .noMatch
    }
}
