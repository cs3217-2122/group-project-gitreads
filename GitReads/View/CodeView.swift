//
//  CodeView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct CodeView: View {
    let file = DummyFile.getFile()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(0..<file.lines.count, id: \.self) { line in
                    HStack {
                        Text(String(line + 1))
                            .padding(.leading) // need to address the width problem
                        LineView(line: file.lines[line])
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView()
.previewInterfaceOrientation(.portrait)
    }
}
