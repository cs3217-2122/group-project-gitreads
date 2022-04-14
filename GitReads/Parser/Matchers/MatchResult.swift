//
//  MatchResult.swift
//  GitReads

// swiftlint:disable fallthrough no_fallthrough_only

/// Represents the result of a match on an `ASTNode`. If a key is supplied with a successful match, then
/// the match result contains a dictionary of the key mapped to the matched node.
enum MatchResult {
    struct Node {
        let type: String
        let start: (line: Int, char: Int)
        let end: (line: Int, char: Int)
    }

    case match(results: [String: Node])
    case noMatch

    static let emptyResultMatch: MatchResult = .match(results: [:])

    static func matchFor(key: String, node: ASTNode) -> MatchResult {
        let results = Node(
            type: node.type,
            start: (line: node.start[0], char: node.start[1]),
            end: (line: node.end[0], char: node.end[1])
        )

        return .match(results: [key: results])
    }

    func combine(_ other: MatchResult) -> MatchResult {
        switch (self, other) {
        case let (.match(a), .match(b)):
            // if both are matched, return a match with the combined results of the
            // dictionaries, prioritizing keys from the first one
            return .match(results: a.merging(b) { a, _ in a })

        // if either result is not a match, then the whole match is considered not a match
        case (_, .noMatch):
            fallthrough
        case (.noMatch, _):
            return .noMatch
        }
    }

    /// If the `MatchResult` is `.noMatch`, returns nil. Otherwise, returns the result of the
    /// extractor applied to the value of the match result.
    func extractResult<T>(_ extractor: ([String: Node]) -> T?) -> T? {
        switch self {
        case let .match(results):
            return extractor(results)
        case .noMatch:
            return nil
        }
    }
}
