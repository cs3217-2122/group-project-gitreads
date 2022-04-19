//
//  CollapsedViewPlugin.swift
//  GitReads
//
//  Created by Liu Zimu on 19/4/22.
//

import SwiftUI

class CollapsedViewPlugin: Plugin {
    func getFileAction(file: File,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> [FileAction] {
        if let value = file.parseOutput.fetchedValue {
            do {
                let lineNum = try value.get().lines.count
                for line in 0..<lineNum where !codeViewModel.lineViewModels[line].isShowing
                && codeViewModel.scopeLineNums.contains(line) {
                    return [FileAction(text: "Expand File",
                                       action: { _, _ in
                        for line in 0..<lineNum {
                            codeViewModel.lineViewModels[line].isShowing = true
                        }
                    }, view: nil)
                    ]
                }

                return [FileAction(text: "Collapse File",
                                   action: { _, _ in
                    for line in 0..<lineNum {
                        if codeViewModel.collapsedScopeLineNums.contains(line) {
                            codeViewModel.lineViewModels[line].isShowing = true
                        } else {
                            codeViewModel.lineViewModels[line].isShowing = false
                        }
                    }
                }, view: nil)
                ]
            } catch {
                return []
            }
        }
        return []
    }

    func getTokenAction(file: File,
                        lineNum: Int,
                        posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> [TokenAction] {
        []
    }

    func getLineAction(file: File,
                       lineNum: Int,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> [LineAction] {
        []
    }

}
