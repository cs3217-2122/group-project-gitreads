//
//  CodeCollapsePlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 16/4/22.
//

import SwiftUI

class CodeCollapsePlugin: Plugin {
    func getLineAction(file: File,
                       lineNum: Int,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> LineAction? {
        if let value = file.parseOutput.fetchedValue {
            do {
                let scopes = try value.get().scopes
                for scope in scopes where scope.prefixStart.line == lineNum {
                    if codeViewModel.lineViewModels[lineNum + 1].isShowing {
                        return LineAction(text: "Collapse Code",
                                          action: { _, _, _ in
                            for line in (scope.prefixStart.line + 1)..<scope.end.line {
                                codeViewModel.lineViewModels[line].isShowing = false
                            }
                                          },
                                          view: nil)
                    }
                    return LineAction(text: "Expand Code",
                                      action: { _, _, _ in
                        for line in (scope.prefixStart.line + 1)..<scope.end.line {
                            codeViewModel.lineViewModels[line].isShowing = true
                        }
                                      },
                                      view: nil)
                }
            } catch {
                return nil
            }
        }
        return nil
    }

    func getTokenAction(file: File,
                        lineNum: Int,
                        posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> TokenAction? {
        nil
    }
}
