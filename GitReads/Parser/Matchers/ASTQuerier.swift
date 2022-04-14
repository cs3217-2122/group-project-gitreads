//
//  ASTQuerier.swift
//  GitReads

struct Query<Result> {
    let matcher: Matcher
    let resultExtractor: ([String: MatchResult.Node]) -> Result?
}

struct ASTQuerier {
    let root: ASTNode

    init(root: ASTNode) {
        self.root = root
    }

    func doQuery<Result>(_ query: Query<Result>) -> [Result] {
        doQuery(query, node: root)
    }

    private func doQuery<Result>(_ query: Query<Result>, node: ASTNode) -> [Result] {
        let matchResult = query.matcher.match(node: node)
        let result = matchResult.extractResult(query.resultExtractor)

        let childResults = node.children.flatMap { doQuery(query, node: $0) }
        if let result = result {
            return [result] + childResults
        }

        return childResults
    }
}
