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
        }
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView(token: Token(type: .keyword, value: "TEST"))
    }
}
