//
//  ScrollLineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 15/3/22.
//

import SwiftUI

struct ScrollLineView: View {
    let line: Line
    @Binding var fontSize: Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach((0..<line.tokens.count), id: \.self) { pos in
                    TokenView(token: line.tokens[pos], fontSize: $fontSize)
                }
            }
        }

    }
}

struct ScrollLineView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        ScrollLineView(line: Line(tokens: [Token(type: .keyword, value: "1TESgfdgdfgsdfgdfsgdfgdsfgdsfgfgT"),
                                           Token(type: .keyword, value: "2TfdgdfgdsfgdsfgdfgdfgEST"),
                                           Token(type: .keyword, value: "3TEST"),
                                           Token(type: .keyword, value: "4TEST"),
                                           Token(type: .keyword, value: "5TEST"),
                                           Token(type: .keyword, value: "6TEST"),
                                           Token(type: .keyword, value: "7TEST"),
                                           Token(type: .keyword, value: "8TEST"),
                                           Token(type: .keyword, value: "9TEST"),
                                           Token(type: .keyword, value: "10TEST"),
                                           Token(type: .keyword, value: "11TEST"),
                                           Token(type: .keyword, value: "12TEST"),
                                           Token(type: .keyword, value: "13TEST"),
                                           Token(type: .keyword, value: "14TEST")]), fontSize: $fontSize)
    }
}
