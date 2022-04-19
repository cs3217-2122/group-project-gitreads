//
//  CodeViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 4/4/22.
//

import Combine

class CodeViewModel: ObservableObject {
    @Published private(set) var parseOutput: ParseOutput?
    @Published var activeFileAction: FileAction?
    @Published var activeLineAction: LineAction?
    @Published var activeTokenAction: TokenAction?
    @Published private(set) var scrollTo: Int?

    @Published var lineViewModels: [LineViewModel] = []

    private var plugins: [Plugin] = [CommentPlugin(), CodeCollapsePlugin(), CollapsedViewPlugin()]
    let file: File

    init(file: File) {
        self.file = file
    }

    var declarations: [Declaration] {
        parseOutput?.declarations ?? []
    }

    var scopes: [Scope] {
        parseOutput?.scopes ?? []
    }

    var collapsedScopeLineNums: [Int] {
        parseOutput?.collapsedScopeLineNums ?? []
    }

    var scopeLineNums: [Int] {
        parseOutput?.scopeLineNums ?? []
    }

    func addPlugin(_ plugin: Plugin) {
        plugins.append(plugin)
    }

    func setParseOutput(_ parseOutput: ParseOutput) {
        guard self.parseOutput == nil else {
            return
        }

        self.parseOutput = parseOutput

        let minificationPlugin = MinificationPlugin(parseOutput: parseOutput)

        let lineViewModels = parseOutput.lines.map { LineViewModel(line: $0) }
        minificationPlugin.registerLines(lineViewModels)

        self.lineViewModels = lineViewModels
        self.plugins.append(minificationPlugin)
    }

    func getFileOption(screenViewModel: ScreenViewModel) -> [FileAction] {
        var result: [FileAction] = []
        for plugin in plugins {
            let action = plugin.getFileAction(file: file,
                                              screenViewModel: screenViewModel,
                                              codeViewModel: self)
            result.append(contentsOf: action)
        }
        return result
    }

    func getLineOption(lineNum: Int,
                       screenViewModel: ScreenViewModel) -> [LineAction] {
        var result: [LineAction] = []
        for plugin in plugins {
            let action = plugin.getLineAction(file: file, lineNum: lineNum,
                                              screenViewModel: screenViewModel, codeViewModel: self)
            result.append(contentsOf: action)
        }
        return result
    }

    func getTokenOption(lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel) -> [TokenAction] {
        var result: [TokenAction] = []
        for plugin in plugins {
            let action = plugin.getTokenAction(file: file, lineNum: lineNum, posNum: posNum,
                                               screenViewModel: screenViewModel, codeViewModel: self)
            result.append(contentsOf: action)
        }
        return result
    }

    func resetAction() {
        activeFileAction = nil
        activeLineAction = nil
        activeTokenAction = nil
    }

    func setFileAction(fileAction: FileAction) {
        resetAction()
        activeFileAction = fileAction
    }

    func setLineAction(lineAction: LineAction) {
        resetAction()
        activeLineAction = lineAction
    }

    func setTokenAction(tokenAction: TokenAction) {
        resetAction()
        activeTokenAction = tokenAction
    }

    func setScrollTo(scrollTo: Int?) {
        guard let scrollTo = scrollTo, scrollTo >= 0 else {
            return
        }
        self.scrollTo = scrollTo
    }

    func resetScroll() {
        self.scrollTo = nil
    }
}

extension CodeViewModel: Equatable {
    static func == (lhs: CodeViewModel, rhs: CodeViewModel) -> Bool {
        lhs.file == rhs.file
    }
}
