//
//  WrapLineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct WrapLineView: View {
    // will be in viewmodel logic
    let screenWidth = UIScreen.main.bounds.width - 10
    let padding: CGFloat = 100
    var indetationLevel = 4
    let line: Line
    @Binding var fontSize: Int

    init(line: Line, fontSize: Binding<Int>) {
        _fontSize = fontSize
        self.line = line
    }

    var body: some View {
        if !line.tokens.isEmpty {
            self.generateContent()
        }
    }

    private func generateContent() -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.line.tokens, id: \.self) { token in
                self.item(for: token)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > screenWidth {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if token == self.line.tokens.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {_ in
                        let result = height
                        if token == self.line.tokens.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(for token: Token) -> some View {
        TokenView(token: token, fontSize: $fontSize)
    }
}

struct WrapLineView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        WrapLineView(line: Line(tokens: [Token(type: .keyword, value: "TEST1"),
                                         Token(type: .keyword, value: " "),
                                         Token(type: .keyword, value: "TEST2"),
                                         Token(type: .keyword, value: " "),
                                         Token(type: .keyword, value: "TEST3"),
                                         Token(type: .keyword, value: " "),
                                         Token(type: .keyword, value: "TEST4"),
                                         Token(type: .keyword, value: " "),
                                         Token(type: .keyword, value: "TEST5")]), fontSize: $fontSize)
    }
}
