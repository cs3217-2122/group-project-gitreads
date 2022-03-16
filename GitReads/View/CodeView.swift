//
//  CodeView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct CodeView: View {
    let file: File

    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<file.lines.count, id: \.self) { line in
                    HStack(alignment: .top) {
                        Text(String(line + 1))
                        // WrapLineView(line: file.lines[line]).padding(.horizontal)
                        ScrollLineView(line: file.lines[line])
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width)
                }
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView(file: DummyFile.getFile())
.previewInterfaceOrientation(.portrait)
    }
}
