//
//  WrapLineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct WrapLineView: View {
    // will be in viewmodel logic
    let screenWidth = UIScreen.main.bounds.width
    let padding: CGFloat = 100
    var indetationLevel = 4
    let line: Line
    var group = [[String]]()
    @Binding var fontSize: Int

    init(line: Line, fontSize: Binding<Int>) {
        _fontSize = fontSize
        self.line = line
        self.group = createGroup(line)
    }

    private func createGroup(_ line: Line) -> [[String]] {
        var group = [[String]]()
        var subGroup = [String]()
        var width: CGFloat = padding
        var space = ""
        for _ in 0..<indetationLevel {
            space += " "
        }
        let indentation = UILabel()
        indentation.text = space

        for token in line.tokens {
            let test = UILabel()
            test.text = token.value
            test.sizeToFit()

            if width + test.frame.width < screenWidth {
                width += test.frame.width
                subGroup.append(token.value)
            } else {
                group.append(subGroup)
                subGroup = [space, token.value]
                width = test.frame.width + indentation.frame.width + padding
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
                        TokenView(token: Token(type: .keyword, value: word), fontSize: $fontSize)
                    }
                }
            }
        }

    }
}

struct WrapLineView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        WrapLineView(line: Line(tokens: [Token(type: .keyword, value: "TEST")], indentLevel: 0), fontSize: $fontSize)
    }
}
