//
//  CodeViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 4/4/22.
//

import Combine

class CodeViewModel: ObservableObject {
    @Published var data: [Line] = []
    @Published var activeLineAction: LineAction?
    @Published var activeTokenAction: TokenAction?
    private let plugins: [Plugin] = [GetCommentPlugin(), MakeCommentPlugin(), TestTokenPlugin()]
    let file: File

    init(file: File) {
        self.file = file
    }

    func getLineOption(lineNum: Int,
                       screenViewModel: ScreenViewModel) -> [LineAction] {
        var result: [LineAction] = []
        for plugin in plugins {
            if let action = plugin.getLineAction(file: file, lineNum: lineNum,
                                                 screemViewModel: screenViewModel, codeViewModel: self) {
                result.append(action)
            }
        }
        return result
    }

    func getTokenOption(lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel) -> [TokenAction] {
        var result: [TokenAction] = []
        for plugin in plugins {
            if let action = plugin.getTokenAction(file: file, lineNum: lineNum, posNum: posNum,
                                                  screemViewModel: screenViewModel, codeViewModel: self) {
                result.append(action)
            }
        }
        return result
    }

    func resetAction() {
        activeLineAction = nil
        activeTokenAction = nil
    }

    func setLineAction(lineAction: LineAction) {
        resetAction()
        activeLineAction = lineAction
    }

    func setTokenAction(tokenAction: TokenAction) {
        resetAction()
        activeTokenAction = tokenAction
    }
}
