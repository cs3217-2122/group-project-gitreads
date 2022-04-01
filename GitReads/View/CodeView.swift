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
    @State private var currentActiveAction: ((File, Int, String) -> Void)?
    @State private var editingLine: Int?
    @State private var text = ""

    var body: some View {
        ScrollView {
            LazyVStack {
                if let lines = lines, case let .success(lines) = lines {
                    ForEach(0..<lines.count, id: \.self) { lineNum in
                        HStack(alignment: .center) {
                            Menu(String(lineNum + 1)) {
                                let options = viewModel.getLineOption(lineNum: lineNum)
                                ForEach(0..<options.count, id: \.self) { pos in
                                    if let buttonText = options[pos].text {
                                        Button(buttonText, action: options[pos].takeInput
                                                ? { editingLine = lineNum; currentActiveAction = options[pos].action }
                                                : { options[pos].action(file, lineNum, "") })
                                    }
                                }
                            }.font(.system(size: CGFloat($fontSize.wrappedValue)))
                            VStack {
                                if isScrollView {
                                    ScrollLineView(viewModel: viewModel, line: lines[lineNum],
                                                   lineNum: lineNum, fontSize: $fontSize)
                                } else {
                                    WrapLineView(viewModel: viewModel, lineNum: lineNum,
                                                 line: lines[lineNum], fontSize: $fontSize).padding(.horizontal)
                                }
                                if editingLine == lineNum, let action = currentActiveAction {
                                    TextField("Enter", text: $text, onCommit: {
                                        action(file, lineNum, text)
                                        text = ""
                                        editingLine = nil
                                        currentActiveAction = nil
                                    })
                                }
                            }
                            Spacer()
                        }.padding(.leading, 6)
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
    @State static var bool = true
    static var previews: some View {
        CodeView(
            file: DummyFile.getFile(),
            viewModel: ScreenViewModel(),
            fontSize: $fontSize,
            isScrollView: $bool
        ).previewInterfaceOrientation(.portrait)
    }
}
