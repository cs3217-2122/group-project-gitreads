//
//  Scope.swift
//  GitReads

struct Scope: Codable, Hashable {
    struct Index: Codable, Hashable {
        let line: Int
        let char: Int

        init(line: Int, char: Int) {
            self.line = line
            self.char = char
        }
    }

    let prefixStart: Index
    let prefixEnd: Index
    let end: Index

    init(prefixStart: Scope.Index, prefixEnd: Scope.Index, end: Scope.Index) {
        self.prefixStart = prefixStart
        self.prefixEnd = prefixEnd
        self.end = end
    }

    func contains(line: Line) -> Bool {
        contains(lineNumber: line.lineNumber)
    }

    func contains(token: Token, onLineNumber lineNumber: Int) -> Bool {
        if !contains(lineNumber: lineNumber) {
            return false
        }

        if lineNumber == prefixStart.line {
            return token.startIdx >= prefixStart.char
        }

        if lineNumber == end.line {
            return token.endIdx <= end.char
        }

        return true
    }

    func contains(declaration: Declaration) -> Bool {
        let linesContained = declaration.start[0] >= prefixStart.line && declaration.end[0] <= end.line
        if !linesContained {
            return false
        }

        if declaration.start[0] == prefixStart.line {
            return declaration.start[1] >= prefixStart.char
        }

        if declaration.end[0] == end.line {
            return declaration.end[1] <= end.char
        }

        return true
    }

    private func contains(lineNumber: Int) -> Bool {
        lineNumber >= prefixStart.line && lineNumber <= end.line
    }
}
