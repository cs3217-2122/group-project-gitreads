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

    private let optsPublisher = CurrentValueSubject<[FileNavigateOption], Never>([])

    init(token: Token, language: Language) {
        self.token = token
        self.language = language
        print("Init with \(token) \(language)")
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
        let state = DefinitionLookupState(options: optsPublisher)
        optsPublisher.send(navigationOptions)
        Task {
            for file in self.asyncVisit {
                let parseOutput = await file.parseOutput.value
                if case let .success(parseOutput) = parseOutput {
                    self.optsPublisher.send(self.optsPublisher.value + checkFile(file: file, parseOutput: parseOutput))
                }
            }
            self.optsPublisher.send(completion: .finished)
        }
        return state
    }

    private func checkFile(file: File, parseOutput: ParseOutput) -> [FileNavigateOption] {
        if token.type != .type && token.type != .functionCall && token.type != .methodCall {
            return []
        }
        var options = [FileNavigateOption]()
        let lines = parseOutput.lines

        for declaration in parseOutput.declarations where declaration.identifier == self.token.value {
            print(declaration.identifier, self.token.value)
            print(declaration)
            let lineNum = declaration.start[0]
            if lineNum >= lines.count {
                continue
            }
            let line = lines[lineNum]
            let preview = line.tokens.map { $0.value }.joined(separator: " ")
            options.append(FileNavigateOption(file: file, line: lineNum, preview: preview))
        }
        return options
    }
}

class DefinitionLookupState: ObservableObject {
    @Published var options: [FileNavigateOption] = []
    @Published var loading = true

    private var subscriptions: Set<AnyCancellable> = []

    init(options: CurrentValueSubject<[FileNavigateOption], Never>) {
        options
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.loading = false
            } receiveValue: { opt in
                self.options = opt
            }
            .store(in: &subscriptions)

    }
}
