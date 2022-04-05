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
    @StateObject var codeViewModel: CodeViewModel
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool

    @State private var lines: Result<[Line], Error>?
    @State private var currentActiveAction: ((ScreenViewModel, CodeViewModel, Int, String) -> Void)?
    @State private var editingLine: Int?
    @State private var text = ""

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<codeViewModel.data.count, id: \.self) { lineNum in
                    HStack(alignment: .center) {
                        Menu(String(lineNum + 1)) {
                            let options = codeViewModel.getLineOption(repo: viewModel.repo, lineNum: lineNum)
                            ForEach(0..<options.count, id: \.self) { pos in
                                if let buttonText = options[pos].text {
                                    Button(buttonText, action: options[pos].takeInput
                                           ? { editingLine = lineNum; currentActiveAction = options[pos].action }
                                            : { options[pos].action(viewModel, codeViewModel, lineNum, "") })
                                }
                            }
                        }.font(.system(size: CGFloat($fontSize.wrappedValue)))

                        VStack {
                            if isScrollView {
                                ScrollLineView(viewModel: viewModel, codeViewModel: codeViewModel,
                                               line: codeViewModel.data[lineNum], lineNum: lineNum,
                                               fontSize: $fontSize)
                            } else {
                                WrapLineView(viewModel: viewModel, lineNum: lineNum,
                                             line: codeViewModel.data[lineNum], fontSize: $fontSize)
                                .padding(.horizontal)
                            }
                            if editingLine == lineNum, let action = currentActiveAction {
                                TextField("Enter", text: $text, onCommit: {
                                    action(viewModel, codeViewModel, lineNum, text)
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
        .onAppear {
            Task {
                self.lines = await file.parseOutput.value.map { $0.lines }
                if let lines = lines, case let .success(lines) = lines {
                    codeViewModel.data = lines
                }
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
            codeViewModel: CodeViewModel(file: DummyFile.getFile()),
            fontSize: $fontSize,
            isScrollView: $bool
        ).previewInterfaceOrientation(.portrait)
    }
}
