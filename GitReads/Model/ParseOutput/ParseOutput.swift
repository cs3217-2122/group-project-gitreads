//
//  ParseOutput.swift
//  GitReads

struct ParseOutput: Codable {
    let fileContents: String
    let lines: [Line]
    var declarations: [Declaration]
    let scopes: [Scope]
    let scopeLineNums: [Int]
    let collapsedScopeLineNums: [Int]

    lazy var declarationsInScope: [Scope: [Declaration]] = {
        scopes.reduce(into: [Scope: [Declaration]]()) { dict, scope in
            dict[scope] = declarations.filter { scope.contains(declaration: $0) }
        }
    }()

    lazy var tokensInScope: [Scope: [Token]] = {
        scopes.reduce(into: [Scope: [Token]]()) { dict, scope in
            let containedTokens = lines.flatMap { line -> [Token] in
                if !scope.contains(line: line) {
                    return []
                }

                return line.tokens.filter { scope.contains(token: $0, onLineNumber: line.lineNumber) }
            }

            dict[scope] = containedTokens
        }
    }()

    init(fileContents: String, lines: [Line], declarations: [Declaration], scopes: [Scope]) {
        self.fileContents = fileContents
        self.lines = lines
        self.declarations = declarations
        self.scopes = scopes
        self.scopeLineNums = ParseOutput.getScopeLineNums(scopes: scopes)
        self.collapsedScopeLineNums = ParseOutput.getCollapsedScopeLineNums(scopes: scopes, lines: lines)
    }

    private static func getCollapsedScopeLineNums(scopes: [Scope], lines: [Line]) -> [Int] {
        var lineNums = [Int]()
        for scope in scopes {
            for i in scope.prefixStart.line...scope.prefixEnd.line {
                lineNums.append(i)
            }
            if scope.prefixEnd.line != scope.end.line {
                lineNums.append(scope.end.line)
                if lines.count > scope.end.line + 1
                    && lines[scope.end.line + 1].content.isEmpty {
                    lineNums.append(scope.end.line + 1)
                }
            }
        }

        if !lineNums.isEmpty && !lines.isEmpty && lines[lineNums[lineNums.count - 1]].content.isEmpty {
            lineNums.remove(at: lineNums.count - 1)
        }

        return lineNums
    }

    private static func getScopeLineNums(scopes: [Scope]) -> [Int] {
        var lineNums = [Int]()
        for scope in scopes {
            for i in scope.prefixStart.line...scope.end.line {
                lineNums.append(i)
            }
        }

        return lineNums
    }

    private enum CodingKeys: CodingKey {
        case fileContents
        case lines
        case scopes
        case scopeLineNums
        case scopePrefixLineNums
        case variableDeclaration
        case functionDeclaration
        case classDeclaration
        case structDeclaration
        case typeDeclaration
        case preprocDeclaration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileContents = try container.decode(String.self, forKey: .fileContents)
        lines = try container.decode([Line].self, forKey: .lines)
        scopes = try container.decode([Scope].self, forKey: .scopes)
        scopeLineNums = try container.decode([Int].self, forKey: .scopeLineNums)
        collapsedScopeLineNums = try container.decode([Int].self, forKey: .scopePrefixLineNums)

        declarations = []
        declarations += try container.decode([VariableDeclaration].self,
                                             forKey: .variableDeclaration)
        declarations += try container.decode([FunctionDeclaration].self,
                                             forKey: .functionDeclaration)
        declarations += try container.decode([ClassDeclaration].self,
                                             forKey: .classDeclaration)
        declarations += try container.decode([StructDeclaration].self,
                                             forKey: .structDeclaration)
        declarations += try container.decode([TypeDeclaration].self,
                                             forKey: .typeDeclaration)
        declarations += try container.decode([PreprocDeclaration].self,
                                             forKey: .preprocDeclaration)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileContents, forKey: .fileContents)
        try container.encode(lines, forKey: .lines)
        try container.encode(scopes, forKey: .scopes)
        try container.encode(scopeLineNums, forKey: .scopeLineNums)
        try container.encode(collapsedScopeLineNums, forKey: .scopePrefixLineNums)

        let variableDeclarations = declarations.compactMap { $0 as? VariableDeclaration }
        let functionDeclarations = declarations.compactMap { $0 as? FunctionDeclaration }
        let classDeclarations = declarations.compactMap { $0 as? ClassDeclaration }
        let structDeclarations = declarations.compactMap { $0 as? StructDeclaration }
        let typeDeclarations = declarations.compactMap { $0 as? TypeDeclaration }
        let preprocDeclarations = declarations.compactMap { $0 as? PreprocDeclaration }

        try container.encode(variableDeclarations, forKey: .variableDeclaration)
        try container.encode(functionDeclarations, forKey: .functionDeclaration)
        try container.encode(classDeclarations, forKey: .classDeclaration)
        try container.encode(structDeclarations, forKey: .structDeclaration)
        try container.encode(typeDeclarations, forKey: .typeDeclaration)
        try container.encode(preprocDeclarations, forKey: .preprocDeclaration)
    }
}
