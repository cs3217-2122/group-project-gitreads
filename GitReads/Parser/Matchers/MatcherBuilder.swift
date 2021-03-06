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

    static func buildExpression(_ matcher: [Matcher]) -> [Matcher] {
        matcher
    }

    static func buildExpression(_ matcher: Matcher?) -> [Matcher] {
        guard let matcher = matcher else {
            return []
        }

        return [matcher]
    }

    static func buildBlock(_ matchers: [Matcher]...) -> [Matcher] {
        matchers.flatMap { $0 }
    }

    static func buildArray(_ matchers: [[Matcher]]) -> [Matcher] {
        matchers.flatMap { $0 }
    }

    static func buildOptional(_ matchers: [Matcher]?) -> [Matcher] {
        matchers ?? []
    }

    static func buildEither(first matchers: [Matcher]) -> [Matcher] {
        matchers
    }

    static func buildEither(second matchers: [Matcher]) -> [Matcher] {
        matchers
    }
}
