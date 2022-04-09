//
//  TokenView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct TokenView: View {
    @StateObject var viewModel: ScreenViewModel
    @StateObject var codeViewModel: CodeViewModel
    let token: Token
    let lineNum: Int
    let pos: Int
    @Binding var fontSize: Int
    @State private var currentActiveAction: ((ScreenViewModel, CodeViewModel, Int, Int, String) -> Void)?
    @State private var text = ""

    var body: some View {
        let options = codeViewModel.getTokenOption(repo: viewModel.repo, lineNum: lineNum, posNum: pos)
        HStack {
            Menu(token.type == .tab ? String(repeating: " ", count: 4) : token.value) {
                ForEach(0..<options.count, id: \.self) { pos in
                    if let buttonText = options[pos].text {
                        Button(buttonText, action: options[pos].takeInput
                               ? { currentActiveAction = options[pos].action }
                               : { options[pos].action(viewModel, codeViewModel, lineNum, pos, "") })
                    }
                }
            }.font(Font.custom("Courier", size: CGFloat($fontSize.wrappedValue)))
            if let action = currentActiveAction {
                TextField("Enter", text: $text, onCommit: {
                    action(viewModel, codeViewModel, lineNum, pos, text)
                    text = ""
                    currentActiveAction = nil
                })
            }
        }
    }
}

struct TokenView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        TokenView(viewModel: ScreenViewModel(),
                  codeViewModel: CodeViewModel(file: DummyFile.getFile()),
                  token: Token(type: .keyword, value: "TEST"),
                  lineNum: 0, pos: 0, fontSize: $fontSize)
    }
}
