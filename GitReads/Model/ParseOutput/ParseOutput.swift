//
//  ParseOutput.swift
//  GitReads

struct ParseOutput: Codable {
    let fileContents: String
    let lines: [Line]
    var declarations: [Declaration]

    init(fileContents: String, lines: [Line], declarations: [Declaration]) {
        self.fileContents = fileContents
        self.lines = lines
        self.declarations = declarations
    }

    private enum CodingKeys: CodingKey {
        case fileContents
        case lines
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
