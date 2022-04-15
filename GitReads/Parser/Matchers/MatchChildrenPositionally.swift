//
//  MatchChildrenPositionally.swift
//  GitReads

/// `MatchChildrenPositionally` accepts an array of children matchers.
/// It matches a node if the all matchers match the corresponding children at the same index.
/// If there are less matchers than children, the excess children will be ignored.
struct MatchChildrenPositionally: Matcher {
    let childrenMatchers: (Int) -> [Matcher]

    init(@MatcherBuilder children: @escaping (Int) -> [Matcher]) {
        self.childrenMatchers = children
    }

    func match(node: ASTNode) -> MatchResult {
        let matchers = childrenMatchers(node.children.count)
        if matchers.isEmpty {
            return .emptyResultMatch
        }

        var match = MatchResult.emptyResultMatch

        for (idx, matcher) in matchers.enumerated() {
            if idx >= node.children.count {
                continue
            }

            let correspondingChild = node.children[idx]
            let matchResult = matcher.match(node: correspondingChild)
            // all positional matches need to match
            switch matchResult {
            case .noMatch:
                return .noMatch
            case .match:
                match = match.combine(matchResult)
            }
        }

        return match
    }
}
