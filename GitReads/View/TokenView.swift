//
//  TokenView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct TokenView: View {
    @StateObject var viewModel: ScreenViewModel
    let token: Token
    let lineNum: Int
    let pos: Int
    @Binding var fontSize: Int
    @State private var showingAlert = false
    @State private var currentActiveAction: ((File, Int, Int, String) -> Void)?

    var body: some View {
        let options = viewModel.getTokenOption(lineNum: lineNum, posNum: pos)
        Menu(token.type == .tab ? String(repeating: " ", count: 4) : token.value) {
            ForEach(0..<options.count, id: \.self) { pos in
                let closure = {} // convert the closure properly
                Button(options[pos].text, action: options[pos].takeInput
                       ? { showingAlert = true; currentActiveAction = options[pos].action }
                       : closure)
            }
        }
        .alert("Action", isPresented: $showingAlert) {
            Text("OK")
        }
        .font(Font.custom("Courier", size: CGFloat($fontSize.wrappedValue)))
        // here can use config file to set colour based on the tokenType
    }
}

struct TokenView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        TokenView(viewModel: ScreenViewModel(), token: Token(type: .keyword, value: "TEST"),
                  lineNum: 0, pos: 0, fontSize: $fontSize)
    }
}
