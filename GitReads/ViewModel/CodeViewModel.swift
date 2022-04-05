//
//  CodeViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 4/4/22.
//

import Combine

class CodeViewModel: ObservableObject {
    @Published var data: [Line] = []
    private let plugins: [Plugin] = [GetCommentPlugin(), MakeCommentPlugin()]
    let file: File

    init(file: File) {
        self.file = file
    }

    func getLineOption(repo: Repo?, lineNum: Int) -> [LineAction] {
        var result: [LineAction] = []
        for plugin in plugins {
            if let action = plugin.getLineAction(repo: repo, file: file, lineNum: lineNum) {
                result.append(action)
            }
        }
        return result
    }

    func getTokenOption(repo: Repo?, lineNum: Int, posNum: Int) -> [TokenAction] {
        var result: [TokenAction] = []
        for plugin in plugins {
            if let action = plugin.getTokenAction(repo: repo, file: file, lineNum: lineNum, posNum: posNum) {
                result.append(action)
            }
        }
        return result
    }
}
