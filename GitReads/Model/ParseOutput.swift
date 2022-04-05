//
//  ParseOutput.swift
//  GitReads

struct ParseOutput: Codable {
    let fileContents: String
    let lines: [Line]
    let declarations: [Declaration]

    init(fileContents: String, lines: [Line], declarations: [Declaration]) {
        self.fileContents = fileContents
        self.lines = lines
        self.declarations = declarations
    }

    private enum CodingKeys: CodingKey {
        case fileContents
        case lines
        case functionDeclaration
        case classDeclaration
        case structDeclaration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileContents = try container.decode(String.self, forKey: .fileContents)
        lines = try container.decode([Line].self, forKey: .lines)

        let functionDeclarations = try container.decode([FunctionDeclaration].self,
                                                        forKey: .functionDeclaration)
        let classDeclarations = try container.decode([ClassDeclaration].self,
                                                     forKey: .classDeclaration)
        let structDeclarations = try container.decode([StructDeclaration].self,
                                                      forKey: .structDeclaration)
        declarations = functionDeclarations + classDeclarations + structDeclarations
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileContents, forKey: .fileContents)
        try container.encode(lines, forKey: .lines)

        let functionDeclarations = declarations.compactMap { $0 as? FunctionDeclaration }
        let classDeclarations = declarations.compactMap { $0 as? ClassDeclaration }
        let structDeclarations = declarations.compactMap { $0 as? StructDeclaration }

        try container.encode(functionDeclarations, forKey: .functionDeclaration)
        try container.encode(classDeclarations, forKey: .classDeclaration)
        try container.encode(structDeclarations, forKey: .structDeclaration)
    }
}
