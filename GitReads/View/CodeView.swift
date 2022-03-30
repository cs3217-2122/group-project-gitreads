//
//  CodeView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct CodeView: View {
    let file: File
    @StateObject var viewModel: ScreenViewModel
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool
    @State private var lines: Result<[Line], Error>?

    var body: some View {
        ScrollView {
            LazyVStack {
                if let lines = lines, case let .success(lines) = lines {
                    ForEach(0..<lines.count, id: \.self) { lineNum in
                        let options = viewModel.getLineOption(lineNum: lineNum)
                        HStack(alignment: .center) {
                            LineNumView(file: file, lineNum: lineNum, options: options)
                                .font(.system(size: CGFloat($fontSize.wrappedValue)))
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

struct LineNumView: View {
    let file: File
    let lineNum: Int
    let options: [PluginAction]

    var body: some View {
        Menu(String(lineNum + 1)) {
            ForEach(0..<options.count, id: \.self) { pos in
                let closure = {}
                Button(options[pos].text, action: closure)
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    @State static var fontSize = 25
    @State static var bool = true
    static var previews: some View {
        CodeView(file: DummyFile.getFile(), viewModel: ScreenViewModel(), fontSize: $fontSize, isScrollView: $bool)
.previewInterfaceOrientation(.portrait)
    }
}
