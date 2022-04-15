//
//  Match.swift
//  GitReads

/// `Match` contains logic to match a specific node.
/// A key can be optionally supplied to store the results of successful matches in the result dictionary
/// under that key.
/// An array of matchers can be passed as a trailing closure to match the children of the node.
///
/// Usage:
/// - Match by type
/// ```
/// Match(type: .exact("function_definition"))
/// ```
///
/// - Match by predicate
/// ```
/// Match { node in  node.type.hasSuffix("declaration") }
/// ```
///
/// - Match with key
/// ```
/// Match(key: "declaration") { node in  node.type.hasSuffix("declaration") }
/// ```
/// or
/// ```
/// Match(type: .exact("function_definition"), key: "definition")
/// ```
///
/// - Match children
/// ```
/// Match(type: .contains("definition")) {
///     Match(type: .exact("identifier"))
/// }
/// ```
///
/// - Match children positionally (ie. the children must be in the exact order indicated by the matchers)
/// ```
/// Match(type: .contains("definition")) { count in
///     for _ in 1..<count {
///         MatchAny()
///     }
///     // only match the last element
///     Match(type: .exact("identifier"))
/// }
/// ```
struct Match: Matcher {
    private let matchFunc: (ASTNode) -> Bool
    private let key: String?
    private let childrenMatcher: Matcher

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
        self.matchFunc = matchFunc
        self.key = key
        self.childrenMatcher = MatchChildren(children: children)
    }

    init(
        key: String? = nil,
        _ matchFunc: @escaping (ASTNode) -> Bool,
        @MatcherBuilder childrenPositionally: @escaping (Int) -> [Matcher]
    ) {
        self.matchFunc = matchFunc
        self.key = key
        self.childrenMatcher = MatchChildrenPositionally(children: childrenPositionally)
    }

    init(
        key: String? = nil,
        _ matchFunc: @escaping (ASTNode) -> Bool
    ) {
        self.matchFunc = matchFunc
        self.key = key
        self.childrenMatcher = MatchAny()
    }

    func match(node: ASTNode) -> MatchResult {
        let matched = matchFunc(node)
        if !matched {
            return .noMatch
        }

        guard let key = key else {
            return .emptyResultMatch.combine(childrenMatcher.match(node: node))
        }

        return .matchFor(key: key, node: node).combine(childrenMatcher.match(node: node))
    }
}

enum NodeTypeMatcher {
    case exact(String)
    case contains(String)
    case oneOf([String])

    func match(type: String) -> Bool {
        switch self {
        case let .exact(string):
            return type == string
        case let .contains(string):
            return type.contains(string)
        case let .oneOf(strings):
            return strings.contains { $0 == type }
        }
    }
}
