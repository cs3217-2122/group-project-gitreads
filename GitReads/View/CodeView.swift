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

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(0..<codeViewModel.data.count, id: \.self) { lineNum in
                        HStack(alignment: .center) {
                            Menu(String(lineNum + 1)) {
                                let options = codeViewModel.getLineOption(lineNum: lineNum,
                                                                          screenViewModel: viewModel)
                                ForEach(0..<options.count, id: \.self) { pos in
                                    if let buttonText = options[pos].text {
                                        Button(buttonText, action: {
                                            options[pos].action(viewModel, codeViewModel, lineNum)
                                            codeViewModel.setLineAction(lineAction: options[pos])
                                        })
                                    }
                                }
                            }.font(.system(size: CGFloat($fontSize.wrappedValue)))

                            VStack {
                                if isScrollView {
                                    ScrollLineView(viewModel: viewModel, codeViewModel: codeViewModel,
                                                   line: codeViewModel.data[lineNum], lineNum: lineNum,
                                                   fontSize: $fontSize)
                                } else {
                                    WrapLineView(viewModel: viewModel, codeViewModel: codeViewModel,
                                                 line: codeViewModel.data[lineNum], lineNum: lineNum,
                                                 fontSize: $fontSize)
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

            if let action = codeViewModel.activeLineAction {
                action.pluginView
            }

            if let action = codeViewModel.activeTokenAction {
                action.pluginView
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
