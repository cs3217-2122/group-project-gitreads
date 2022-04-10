//
//  DefinitionLookupPlugin.swift
//  GitReads

import Foundation
import SwiftUI

struct DefinitionLookupPlugin: Plugin {
    let repo: Repo

    func getLineAction(file: File, lineNum: Int, screemViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> LineAction? {
        nil
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int, screemViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> TokenAction? {
        if let parserOutput = file.parseOutput.fetchedValue, case let .success(parserOutput) = parserOutput {
            let token = parserOutput.lines[lineNum].tokens[posNum]

            guard token.type == .methodCall || token.type == .functionCall || token.type == .type else {
                return nil
            }

            let state = repo.accept(visitor: DefinitionLookupVisitor(token: token, language: file.language))
            return TokenAction(
                text: "Definition Lookup",
                action: { _, _, _, _ in },
                view: AnyView(DefinitionLookupView(
                    definitionLookupState: state,
                    token: token,
                    onSelect: screemViewModel.navigateTo(_:)))
            )
        }
        return nil
    }
}

struct DefinitionLookupView: View {
    @StateObject var definitionLookupState: DefinitionLookupState
    let token: Token
    let onSelect: (FileNavigateOption) -> Void

    var body: some View {
        VStack {
            List {
                ForEach(definitionLookupState.options, id: \.hashValue) { option in
                    NavigationOptionView(searchTerm: token.value, option: option)
                        .onTapGesture {
                            onSelect(option)
                        }
                }

                if definitionLookupState.loading {
                    ProgressView()
                }
            }
        }
    }
}
