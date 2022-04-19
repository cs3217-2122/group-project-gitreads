//
//  MinificationPlugin.swift
//  GitReads

import SwiftUI

class MinificationPlugin: Plugin {

    class MinificationState {
        var minified: Bool {
            didSet {
                for viewModel in viewModels {
                    viewModel.minified = minified
                }
            }
        }

        var viewModels: [TokenViewModel] = []

        init(minified: Bool) {
            self.minified = minified
        }

        func addViewModel(_ viewModel: TokenViewModel) {
            viewModels.append(viewModel)
            viewModel.minified = minified
        }

        func toggle() {
            minified.toggle()
        }
    }

    var parseOutput: ParseOutput

    var minificationStates: [Token: MinificationState] = [:]

    init(parseOutput: ParseOutput) {
        self.parseOutput = parseOutput

        // sort the scopes by size, where the largest scope comes first
        let sortedScopes = parseOutput.scopes.sorted { a, b in
            let aSize = (
                line: a.end.line - a.prefixStart.line,
                char: a.end.char - a.prefixStart.char
            )
            let bSize = (
                line: b.end.line - b.prefixStart.line,
                char: b.end.char - b.prefixStart.char
            )

            if aSize.line != bSize.line {
                return aSize.line > bSize.line
            }

            return aSize.char > bSize.char
        }

        // collate the mappings of declarations to their smallest surrounding scope.
        // since the scopes are sorted by size in descending order, the smallest
        // surrounding scope will override larger scopes.
        var declarationsToScopes: [DeclarationKey: Scope] = [:]
        for scope in sortedScopes {
            let declarations = self.parseOutput.declarationsInScope[scope, default: []]
            for declaration in declarations {
                declarationsToScopes[declaration.key] = scope
            }
        }

        // for every declaration, create a minification state and track the tokens
        // that refer to it in scope. for each of those tokens, map them to the
        // minification state for that declaration for quick lookup.
        for (declaration, scope) in declarationsToScopes {
            let minificationState = MinificationState(minified: false)
            let tokens = self.parseOutput.tokensInScope[scope, default: []]

            for token in tokens {
                if validToken(token) && token.value == declaration.identifier {
                    minificationStates[token] = minificationState
                }
            }
        }
    }

    func getFileAction(file: File, screenViewModel: ScreenViewModel, codeViewModel: CodeViewModel) -> [FileAction] {
        []
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
    ) -> [TokenAction] {
        let tokenViewModel = codeViewModel.lineViewModels[lineNum].tokenViewModels[posNum]
        guard let state = minificationStates[tokenViewModel.token] else {
            return []
        }

        return [TokenAction(
            text: state.minified ? "Show full" : "Minify",
            action: { _, _, _, _ in
                    state.toggle()
            },
            view: nil
        )]
    }

    func registerLines(_ lineViewModels: [LineViewModel]) {
        let minLineLength = minLineLengthToMinify()

        for lineViewModel in lineViewModels {
            for tokenViewModel in lineViewModel.tokenViewModels {
                let token = tokenViewModel.token
                guard let minificationState = minificationStates[token] else {
                    continue
                }

                minificationState.addViewModel(tokenViewModel)
                let lineLength = lineViewModel.line.content.count
                if lineLength >= minLineLength && !minificationState.minified {
                    minificationState.minified = true
                }
            }
        }
    }

    private func validToken(_ token: Token) -> Bool {
        let typeValid = token.type == .variable || token.type == .property
        let lengthValid = token.value.count > 4
        return typeValid && lengthValid
    }

    private func minLineLengthToMinify() -> Int {
        var fontSize = UserDefaults.standard.integer(forKey: SettingViewModel.fontSizeKey)
        if fontSize == 0 {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                fontSize = 18
            case .pad:
                fontSize = 25
            default:
                fontSize = 25
            }
        }

        let screenWidth = UIScreen.main.bounds.width
        let font = UIFont(name: "Courier", size: CGFloat(fontSize))

        let charWidth = " ".width(for: font)
        return Int(ceil(screenWidth / charWidth) - 2) // subtract 2 to roughly account for the line margin
    }
}
