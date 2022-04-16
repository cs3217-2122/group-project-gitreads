//
//  ScrollLineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 15/3/22.
//

import SwiftUI

struct ScrollLineView: View {
    @StateObject var viewModel: ScreenViewModel
    @StateObject var codeViewModel: CodeViewModel
    @ObservedObject var lineViewModel: LineViewModel

    let lineNum: Int
    let activeTheme: Theme

    @Binding var fontSize: Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
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
}

struct ScrollLineView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        ScrollLineView(
            viewModel: ScreenViewModel(),
            codeViewModel: CodeViewModel(file: DummyFile.getFile()),
            lineViewModel: LineViewModel(line: Line(lineNumber: 0, tokens: [
                Token(type: .keyword, value: "1TESgfdgdfgsdfgdfsgdfgdsfgdsfgfgT", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "2TfdgdfgdsfgdsfgdfgdfgEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "3TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "4TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "5TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "6TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "7TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "8TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "9TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "10TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "11TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "12TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "13TEST", startIdx: 0, endIdx: 1),
                Token(type: .keyword, value: "14TEST", startIdx: 0, endIdx: 1)
            ])),
            lineNum: 1,
            activeTheme: OneLightTheme(),
            fontSize: $fontSize
        )
    }
}
