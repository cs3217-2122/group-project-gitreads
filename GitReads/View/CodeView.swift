//
//  CodeView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct CodeView: View {
    let file: File
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<file.lines.count, id: \.self) { line in
                    HStack(alignment: .top) {
                        Text(String(line + 1)).font(.system(size: CGFloat($fontSize.wrappedValue)))
                        if isScrollView {
                            ScrollLineView(line: file.lines[line], fontSize: $fontSize)
                        } else {
                            WrapLineView(line: file.lines[line], fontSize: $fontSize).padding(.horizontal)
                        }
                        // Spacer()
                    }.frame(width: UIScreen.main.bounds.width)
                }
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    @State static var fontSize = 25
    @State static var bool = true
    static var previews: some View {
        CodeView(file: DummyFile.getFile(), fontSize: $fontSize, isScrollView: $bool)
.previewInterfaceOrientation(.portrait)
    }
}
