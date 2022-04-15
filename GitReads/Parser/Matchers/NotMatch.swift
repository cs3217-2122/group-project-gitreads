//
//  NotMatch.swift
//  GitReads

/// `NotMatch` has the same API as `Match` but only matches the negation of the given predicate.
/// Note that this negation does not apply to the children, ie. any matchers for child nodes are applied
/// normally.
struct NotMatch: Matcher {
    private let matcher: Match

    init(
        type nodeTypeMatcher: NodeTypeMatcher,
        key: String? = nil,
        @MatcherBuilder children: @escaping () -> [Matcher]
    ) {
        self.init(
            key: key, { nodeTypeMatcher.match(type: $0.type) },
            children: children
        )
    }

    init(
        type nodeTypeMatcher: NodeTypeMatcher,
        key: String? = nil,
        @MatcherBuilder childrenPositionally: @escaping (Int) -> [Matcher]
    ) {
        self.init(
            key: key, { nodeTypeMatcher.match(type: $0.type) },
            childrenPositionally: childrenPositionally
        )
    }

    init(
        type nodeTypeMatcher: NodeTypeMatcher,
        key: String? = nil
    ) {
        self.init(
            key: key, { nodeTypeMatcher.match(type: $0.type) }
        )
    }

    init(
        key: String? = nil,
        _ matchFunc: @escaping (ASTNode) -> Bool,
        @MatcherBuilder children: @escaping () -> [Matcher]
    ) {
        self.matcher = Match(key: key, { !matchFunc($0) }, children: children)
    }

    init(
        key: String? = nil,
        _ matchFunc: @escaping (ASTNode) -> Bool,
        @MatcherBuilder childrenPositionally: @escaping (Int) -> [Matcher]
    ) {
        self.matcher = Match(key: key, { !matchFunc($0) }, childrenPositionally: childrenPositionally)
    }

    init(
        key: String? = nil,
        _ matchFunc: @escaping (ASTNode) -> Bool
    ) {
        self.matcher = Match(key: key, { !matchFunc($0) })
    }

    func match(node: ASTNode) -> MatchResult {
        matcher.match(node: node)
    }
}
