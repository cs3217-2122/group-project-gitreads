//
//  LineViewModel.swift
//  GitReads

import Combine

class LineViewModel: ObservableObject {
    let line: Line
    let tokenViewModels: [TokenViewModel]
    var isShowing = true

    init(line: Line) {
        self.line = line
        self.tokenViewModels = line.tokens.map { TokenViewModel(token: $0) }
    }
}
