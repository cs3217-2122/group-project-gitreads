//
//  TokenView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct TokenView: View {
    let token: Token
    @Binding var fontSize: Int

    var body: some View {
        Menu(token.value) {
            Text(token.type.rawValue)
        }
        .font(Font.custom("Courier", size: CGFloat($fontSize.wrappedValue)))
        // here can use config file to set colour based on the tokenType
    }
}

struct TokenView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        TokenView(token: Token(type: .keyword, value: "TEST"), fontSize: $fontSize)
    }
}
