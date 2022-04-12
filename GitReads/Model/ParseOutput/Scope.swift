//
//  Scope.swift
//  GitReads

struct Scope: Codable, Hashable {
    struct Index: Codable, Hashable {
        let line: Int
        let char: Int
    }

    let prefixStart: Index
    let prefixEnd: Index
    let end: Index

    func contains(line: Line) -> Bool {
        contains(lineNumber: line.lineNumber)
    }

    func contains(token: Token, onLineNumber lineNumber: Int) -> Bool {
        if !contains(lineNumber: lineNumber) {
            return false
        }

        return token.startIdx >= prefixStart.char && token.endIdx <= end.char
    }

    func contains(declaration: Declaration) -> Bool {
        declaration.start[0] >= prefixStart.line
        && declaration.end[0] <= end.line
        && declaration.start[1] >= prefixStart.char
        && declaration.end[1] <= end.char
    }

    private func contains(lineNumber: Int) -> Bool {
        lineNumber >= prefixStart.line && lineNumber <= end.line
    }
}
