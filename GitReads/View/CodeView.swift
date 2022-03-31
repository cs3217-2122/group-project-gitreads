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
    @State private var lines: Result<[Line], Error>?

    var body: some View {
        ScrollView {
            LazyVStack {
                if let lines = lines, case let .success(lines) = lines {
                    ForEach(0..<lines.count, id: \.self) { lineNum in
                        HStack(alignment: .center) {
                            Text(String(lineNum + 1)).font(.system(size: CGFloat($fontSize.wrappedValue)))
                                .padding(.trailing, 3)
                            if isScrollView {
                                ScrollLineView(line: lines[lineNum], fontSize: $fontSize)
                            } else {
                                WrapLineView(line: lines[lineNum], fontSize: $fontSize).padding(.horizontal)
                            }
                            Spacer()
                        }
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.leading, 6)
                    }
                }
            }
        }
        .onAppear {
            Task {
                self.lines = await file.lines.value
            }
        }

        if lines == nil {
            ProgressView()
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    @State static var fontSize = 25
    @State static var bool = false
    static var previews: some View {
        CodeView(file: DummyFile.getFile(), fontSize: $fontSize, isScrollView: $bool)
            .previewInterfaceOrientation(.portrait)
    }
}
