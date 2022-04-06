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
    let line: Line
    let lineNum: Int
    @Binding var fontSize: Int

    var body: some View {
        WrappingHStack(id: \.self, alignment: .leading) {
            ForEach((0..<line.tokens.count), id: \.self) { pos in
                TokenView(viewModel: viewModel, codeViewModel: codeViewModel, token: line.tokens[pos],
                          lineNum: lineNum, pos: pos, fontSize: $fontSize)
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
            line: Line(tokens: [
                Token(type: .keyword, value: "TEST"),
                Token(type: .keyword, value: " "),
                Token(type: .keyword, value: "TEST"),
                Token(type: .keyword, value: " "),
                Token(type: .keyword, value: "TEST"),
                Token(type: .keyword, value: "TEST"),
                Token(type: .keyword, value: "TEST"),
                Token(type: .keyword, value: "TEST"),
                Token(type: .keyword, value: "TEST")
            ]),
            lineNum: 0,
            fontSize: $fontSize)
    }
}
