//
//  MinificationPlugin.swift
//  GitReads

import SwiftUI

class MinificationPlugin: Plugin {

    class MinificationState {
        var minified: Bool
        var viewModels: [TokenViewModel] = []

        init(minified: Bool) {
            self.minified = minified
        }

        func addViewModel(_ viewModel: TokenViewModel) {
            viewModels.append(viewModel)
        }

        func toggle() {
            minified.toggle()
            for viewModel in viewModels {
                viewModel.minified = minified
            }
        }
    }

    let parseOutput: ParseOutput
    // TODO: need to enable scope level awareness
    var minificationStates: [String: MinificationState] = [:]

    init(parseOutput: ParseOutput) {
        self.parseOutput = parseOutput
    }

    func getLineAction(
        file: File,
        lineNum: Int,
        screenViewModel: ScreenViewModel,
        codeViewModel: CodeViewModel
    ) -> [LineAction] {
        []
    }

    func getTokenAction(
        file: File,
        lineNum: Int,
        posNum: Int,
        screenViewModel: ScreenViewModel,
        codeViewModel: CodeViewModel
    ) -> TokenAction? {
        let tokenViewModel = codeViewModel.lineViewModels[lineNum].tokenViewModels[posNum]
        guard let state = minificationStates[tokenViewModel.token.value] else {
            return nil
        }

        return TokenAction(
            text: state.minified ? "Show full" : "Minify",
            action: { _, _, _, _ in
                state.toggle()
            },
            view: nil
        )
    }

    func registerLines(_ lineViewModels: [LineViewModel]) {
        for lineViewModel in lineViewModels {
            for tokenViewModel in lineViewModel.tokenViewModels {
                // TODO: add proper logic to determine whether should minify
                let token = tokenViewModel.token
                guard token.type == .variable && token.value.count > 5 else {
                    continue
                }

                tokenViewModel.minified = true
                let state = minificationStates[token.value, default: MinificationState(minified: true)]
                state.addViewModel(tokenViewModel)
                minificationStates[token.value] = state
            }
        }
    }

    // TODO: possibly add a top level option to minify/show everything
}
