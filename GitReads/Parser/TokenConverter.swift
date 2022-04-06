//
//  FileConverter.swift
//  GitReads
//  Convert an array of tokens into file object
//
//  Created by Liu Zimu on 21/3/22.
//

import Foundation

class TokenConverter {

    // Convert an array of AST Nodes to an array of Line object
    static func nodesToLines(fileString: String, nodes: [ASTNode]) -> [Line] {
        guard !nodes.isEmpty else {
            return []
        }

        let lines = breakStringByline(fileString)

        // Represent an array of lines, where each line is an array of token
        var tokens = [[Token]]()
        for _ in 0..<lines.count {
            tokens.append([Token]())
        }

        // Starting position of next token
        var nextStartPosition = 0

        for node in nodes {
            let nodeType = TokenType(rawValue: node.type) ?? .otherType

            var lineNumber = node.start[0]

            addSpace(line: lines[lineNumber],
                     rawTokenStart: node.start,
                     rawTokenEnd: node.end,
                     lineTokens: &tokens[lineNumber],
                     nextStartPosition: &nextStartPosition)

            // Get strings from token positions
            let strings = getTokenString(lines: lines, start: node.start, end: node.end)

            // If the token spans multiple lines, split into multiple tokens
            for string in strings {
                tokens[lineNumber].append(Token(type: nodeType, value: String(string)))
                lineNumber += 1
            }
        }

        return tokensToLines(tokens)
    }

    private static func addSpace(line: String.UTF8View,
                                 rawTokenStart: [Int],
                                 rawTokenEnd: [Int],
                                 lineTokens: inout [Token],
                                 nextStartPosition: inout Int
    ) {
        if lineTokens.isEmpty {
            let indent = rawTokenStart[1]
            if indent > 0 {
                var start = 0
                while String(getSubstring(line: line, start: start, end: start + 1)) == "\t" {
                    // If the indent is tab, insert tab token(s)
                    lineTokens.append(getTabToken())
                    start += 1
                }

                let numSpaces = indent - start
                // Add spaces before first token in each line
                // based on indent size - number of tabs
                if numSpaces > 0 {
                    lineTokens.append(getSpaceToken(numSpaces))
                }
            }
        } else if nextStartPosition < rawTokenStart[1] {
            // If space detected, add a space token
            let count = rawTokenStart[1] - nextStartPosition
            lineTokens.append(getSpaceToken(count))
        }
        nextStartPosition = rawTokenEnd[1]
    }

    // Return a space token with given number of spaces
    private static func getSpaceToken(_ spaceCount: Int) -> Token {
        Token(type: .space,
              value: String(repeating: " ", count: spaceCount))
    }

    // Return a tab token
    private static func getTabToken() -> Token {
        Token(type: .tab, value: "\t")
    }

    // Return string from start position to end position in file,
    // If it is a multiline string, break into multiple strings.
    static func getTokenString(lines: [String.UTF8View], start: [Int], end: [Int]) -> [String.UTF8View] {
        if start[0] == end[0] {
            // If the token is on one line, return a single string
            let line = lines[start[0]]
            return [getSubstring(line: line, start: start[1], end: end[1])]
        } else {
            // If the token is on multiple lines, return multiple strings where each line is a string
            var strings = [String.UTF8View]()
            let startLine = lines[start[0]]
            // Only add the token if it is non-empty
            if start[1] < startLine.count {
                strings.append(getSubstring(line: startLine, start: start[1], end: startLine.count))
            }

            // If there are at least 3 lines, add more lines
            if start[0] + 1 <= end[0] - 1 {
                for lineNumber in (start[0] + 1)...(end[0] - 1) {
                    strings.append(lines[lineNumber])
                }
            }

            let endLine = lines[end[0]]
            if end[1] > 0 {
                strings.append(getSubstring(line: endLine, start: 0, end: end[1]))
            }
            return strings
        }
    }

    // Return a subtring from a line, start inclusive, end exclusive
    private static func getSubstring(line: String.UTF8View, start: Int, end: Int) -> String.UTF8View {
        let start = line.index(line.startIndex, offsetBy: start)
        let offset = end - line.count
        let end = line.index(line.endIndex, offsetBy: offset)
        let range = start..<end
        return String(line[range])?.utf8 ?? "".utf8
    }

    // Convert a 2D token array to an array of lines
    private static func tokensToLines(_ tokens: [[Token]]) -> [Line] {
        var lines = [Line]()
        for lineTokens in tokens {
            lines.append(Line(tokens: lineTokens))
        }
        return lines
    }

    static func breakStringByline(_ string: String) -> [String.UTF8View] {
        string.components(separatedBy: "\n").map { String($0).utf8 }
    }
}
