//
//  TokenView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct TokenView: View {
    var token: Token
    var body: some View {
        Menu(token.value) {
            Text(token.type.rawValue)
        }.fixedSize(horizontal: false, vertical: true).accentColor(.blue)
        // here can use config file to set colour based on the tokenType
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView(token: Token(type: .keyword, value: "TEST"))
    }
}
