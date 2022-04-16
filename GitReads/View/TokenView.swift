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
    @ObservedObject var tokenViewModel: TokenViewModel

    let lineNum: Int
    let pos: Int

    var token: Token {
        tokenViewModel.token
    }

    @Binding var fontSize: Int
    @State private var currentActiveAction: ((ScreenViewModel, CodeViewModel, Int, Int, String) -> Void)?
    @State private var text = ""

    func needHighlight(_ tokenActions: [TokenAction]) -> Bool {
        for tokenAction in tokenActions where tokenAction.isHighlighted {
            return true
        }
        return false
    }

    var body: some View {
        let options = codeViewModel.getTokenOption(
            lineNum: lineNum,
            posNum: pos,
            screenViewModel: viewModel
        )
        let text = tokenViewModel.minified
            ? String(token.value.prefix(3) + "…")
            : token.type == .tab
                ? String(repeating: " ", count: 4)
                : token.value

        Menu {
            ForEach(0..<options.count, id: \.self) { pos in
                if let buttonText = options[pos].text {
                    Button(buttonText, action: {
                        options[pos].action(viewModel, codeViewModel, lineNum, pos)
                        codeViewModel.setTokenAction(tokenAction: options[pos])
                    })
                }
            }
        } label: {
            Text(text).background {
                if tokenViewModel.minified {
                    // TODO: can improve looks when minified
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.gray)
                        .opacity(0.15)
                }
            }
        }
        .font(Font.custom("Courier", size: CGFloat($fontSize.wrappedValue)))
        .frame(width: width(text))
        .foregroundColor(needHighlight(options) ? .red : .black)
    }

    func width(_ str: String) -> CGFloat {
        let font = UIFont(name: "Courier", size: CGFloat($fontSize.wrappedValue))
        return str.width(for: font)
    }
}

struct TokenView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        let token = Token(type: .keyword, value: "TEST", startIdx: 0, endIdx: 4)
        TokenView(viewModel: ScreenViewModel(),
                  codeViewModel: CodeViewModel(file: DummyFile.getFile()),
                  tokenViewModel: TokenViewModel(token: token),
                  lineNum: 0, pos: 0, fontSize: $fontSize)
    }
}
