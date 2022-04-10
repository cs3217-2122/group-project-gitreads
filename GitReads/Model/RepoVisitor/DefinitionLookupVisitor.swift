//
//  DefinitionLookupVisitor.swift
//  GitReads

import Foundation
import Combine

class DefinitionLookupVisitor: RepoVisitor {
    private let token: Token
    private let language: Language
    private var navigationOptions: [FileNavigateOption] = []
    private var asyncVisit: [File] = []

    private let publisher = CurrentValueSubject<[FileNavigateOption], Never>([])

    init(token: Token, language: Language) {
        self.token = token
        self.language = language
    }

    func visit(directory: Directory) {}

    func visit(file: File) {
        if file.language != self.language {
            return
        }

        if let parseOutput = file.parseOutput.fetchedValue,
            case let .success(parseOutput) = parseOutput {
            navigationOptions.append(contentsOf: checkFile(file: file, parseOutput: parseOutput))
        } else {
            asyncVisit.append(file)
        }
    }

    func afterVisit() -> DefinitionLookupState {
        let state = DefinitionLookupState(options: navigationOptions, loading: true)
        Task {
            for file in self.asyncVisit {
                let parseOutput = await file.parseOutput.value
                if case let .success(parseOutput) = parseOutput {
                    state.options.append(contentsOf: checkFile(file: file, parseOutput: parseOutput))
                }
            }
            state.loading = false
        }
        return state
    }

    private func checkFile(file: File, parseOutput: ParseOutput) -> [FileNavigateOption] {

        var condition: (Token) -> Bool
        switch token.type {
        case .type:
            // TODO: Information not available
            return []
        case .functionCall:
            condition = { token in
                (token.type == .functionDeclaration || token.type == .specialFunctionDeclaration)
                && token.value == self.token.value
            }
        case .methodCall:
            condition = { token in
                token.type == .methodDeclaration && token.value == self.token.value
            }
        default:
            return []
        }

        var options = [FileNavigateOption]()
        for (i, line) in parseOutput.lines.enumerated() {
            if line.tokens.contains(where: condition) {
                let preview = line.tokens.map { $0.value }.joined(separator: " ")
                options.append(FileNavigateOption(file: file, line: i, preview: preview))
            }

        }
        return options
    }
}

class DefinitionLookupState: ObservableObject {
    @Published var options: [FileNavigateOption]
    @Published var loading: Bool

    init(options: [FileNavigateOption], loading: Bool) {
        self.options = options
        self.loading = loading
    }
}
