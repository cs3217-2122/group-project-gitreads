//
//  WrapLineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI
import WrappingStack

struct WrapLineView: View {
    @StateObject var viewModel: ScreenViewModel
    @StateObject var codeViewModel: CodeViewModel
    @ObservedObject var lineViewModel: LineViewModel

    let lineNum: Int
    let activeTheme: Theme
    @Binding var fontSize: Int

    var body: some View {
        WrappingHStack(id: \.self, alignment: .leading) {
            ForEach((0..<lineViewModel.tokenViewModels.count), id: \.self) { pos in
                TokenView(
                    viewModel: viewModel,
                    codeViewModel: codeViewModel,
                    tokenViewModel: lineViewModel.tokenViewModels[pos],
                    lineNum: lineNum,
                    pos: pos,
                    activeTheme: activeTheme,
                    fontSize: $fontSize
                )
            }
        }
    }
}

struct WrapLineView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        WrapLineView(
            viewModel: ScreenViewModel(),
            codeViewModel: CodeViewModel(file: DummyFile.getFile()),
            lineViewModel: LineViewModel(line: Line(lineNumber: 0, tokens: [
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: " ", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: " ", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 1)
            ])),
            lineNum: 0,
            activeTheme: OneLightTheme(),
            fontSize: $fontSize
        )
    }
}
