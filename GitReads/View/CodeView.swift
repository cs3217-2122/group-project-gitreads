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

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<file.lines.count, id: \.self) { line in
                    HStack(alignment: .top) {
                        Text(String(line + 1))
                        // WrapLineView(line: file.lines[line], fontSize: $fontSize).padding(.horizontal)
                        ScrollLineView(line: file.lines[line], fontSize: $fontSize)
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width)
                }
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    @State static var fontSize = 25
    static var previews: some View {
        CodeView(file: DummyFile.getFile(), fontSize: $fontSize)
.previewInterfaceOrientation(.portrait)
    }
}
