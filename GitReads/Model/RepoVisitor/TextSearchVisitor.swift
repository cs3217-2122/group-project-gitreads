//
//  TextSearchVisitor.swift
//  GitReads

import Foundation
import Combine

class TextSearchVisitor: RepoVisitor {
    let textSearch: String
    private var navigationOptions: [FileNavigateOption] = []
    private var asyncVisit: [File] = []

    private let publisher = CurrentValueSubject<[FileNavigateOption], Never>([])

    init(textSearch: String) {
        self.textSearch = textSearch
    }

    func visit(directory: Directory) {}

    func visit(file: File) {
        if let lines = file.lines.fetchedValue {
            navigationOptions.append(contentsOf: checkFile(file: file, lines: lines))
        } else {
            asyncVisit.append(file)
        }
    }

    func afterVisit() -> CurrentValueSubject<[FileNavigateOption], Never> {
        publisher.send(navigationOptions)
        Task {
            for file in self.asyncVisit {
                let lines = await file.lines.value
                let options = checkFile(file: file, lines: lines) + self.publisher.value
                publisher.send(options)

            }
        }
        return publisher
    }

    private func checkFile(file: File, lines: Result<[Line], Error>) -> [FileNavigateOption] {
        guard case let .success(lines) = lines else {
            return []
        }
        var options = [FileNavigateOption]()

        for (idx, line) in lines.enumerated() {
            let str = line.tokens.map { $0.value }.joined()
            if str.contains(textSearch) {
                options.append(FileNavigateOption(file: file, line: idx, preview: str))
            }
        }

        return options
    }
}
