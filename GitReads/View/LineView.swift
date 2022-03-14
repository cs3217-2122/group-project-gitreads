//
//  LineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct LineView: View {
    // will be in viewmodel logic
    let screenWidth = UIScreen.main.bounds.width
    let line: Line
    var group = [[String]]()

    init(line: Line) {
        self.line = line
        self.group = createGroup(line)
    }

    private func createGroup(_ line: Line) -> [[String]] {
        var group = [[String]]()
        var subGroup = [String]()
        var width: CGFloat = 100
        for token in line.tokens {
            let test = UILabel()
            test.text = token.value
            test.sizeToFit()

            if width + test.frame.width < screenWidth {
                width += test.frame.width
                subGroup.append(token.value)
            } else {
                group.append(subGroup)
                subGroup = [token.value]
                width = test.frame.width + 100
            }
        }
        group.append(subGroup)
        return group
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(group, id: \.self) { subGroup in
                HStack {
                    ForEach(subGroup, id: \.self) { word in
                        TokenView(token: Token(type: .keyword, value: word)).fixedSize()
                    }
                }
            }
        }

    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(line: Line(tokens: [Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST"),
                                     Token(type: .keyword, value: "TEST")], indentLevel: 0))
    }
}
