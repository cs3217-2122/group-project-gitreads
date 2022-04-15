//
//  MatcherBuilder.swift
//  GitReads

/// `MatcherBuilder` allows arrays of `Matchers` to be constructed in a syntax similar to how views
/// are constructed.
@resultBuilder
struct MatcherBuilder {
    static func buildExpression(_ matcher: Matcher) -> [Matcher] {
        [matcher]
    }

    static func buildBlock(_ matchers: [Matcher]...) -> [Matcher] {
        matchers.flatMap { $0 }
    }

    static func buildArray(_ matchers: [[Matcher]]) -> [Matcher] {
        matchers.flatMap { $0 }
    }
}
