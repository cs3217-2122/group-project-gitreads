//
//  CodeView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct CodeView: View {
    @StateObject var viewModel: ScreenViewModel
    @StateObject var codeViewModel: CodeViewModel
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool

    @State private var parseOutput: Result<ParseOutput, Error>?

    func pluginHeader(_ view: AnyView) -> some View {
        VStack {
            Button("Close") {
                codeViewModel.resetAction()
            }.frame(alignment: .trailing)

            view
        }
    }

    func line(lineNum: Int, reader: ScrollViewProxy) -> some View {
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
                    ScrollLineView(
                        viewModel: viewModel,
                        codeViewModel: codeViewModel,
                        lineViewModel: codeViewModel.lineViewModels[lineNum],
                        lineNum: lineNum,
                        fontSize: $fontSize
                    )
                } else {
                    WrapLineView(
                        viewModel: viewModel,
                        codeViewModel: codeViewModel,
                        lineViewModel: codeViewModel.lineViewModels[lineNum],
                        lineNum: lineNum,
                        fontSize: $fontSize
                    )
                }
            }
            Spacer()
        }
        .id(lineNum)
        .padding(.leading, 6)
        .onAppear {
            if let scrollTo = codeViewModel.scrollTo {
                withAnimation { reader.scrollTo(scrollTo, anchor: .top) }
                codeViewModel.resetScroll()
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack {
                        ForEach(0..<codeViewModel.lineViewModels.count, id: \.self) { lineNum in
                            line(lineNum: lineNum, reader: reader)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    self.parseOutput = await codeViewModel.file.parseOutput.value
                    if let parseOutput = self.parseOutput, case let .success(output) = parseOutput {
                        codeViewModel.setParseOutput(output)
                    }
                }
            }

            if let action = codeViewModel.activeLineAction, let pluginView = action.pluginView {
                pluginHeader(pluginView)
            }

            if let action = codeViewModel.activeTokenAction, let pluginView = action.pluginView {
                pluginHeader(pluginView)
            }
        }

        if parseOutput == nil {
            ProgressView()
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    @State static var fontSize = 25
    @State static var bool = true
    static var previews: some View {
        CodeView(
            viewModel: ScreenViewModel(),
            codeViewModel: CodeViewModel(file: DummyFile.getFile()),
            fontSize: $fontSize,
            isScrollView: $bool
        ).previewInterfaceOrientation(.portrait)
    }
}
