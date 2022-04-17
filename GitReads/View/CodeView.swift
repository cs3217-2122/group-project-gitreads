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
    let activeTheme: Theme

    @State private var parseOutput: Result<ParseOutput, Error>?

    func pluginHeader<T: View>(_ view: T) -> some View {
        VStack(spacing: 0) {
            Button("Close") {
                codeViewModel.resetAction()
            }
            .padding(.vertical, 10)

            HStack {
                Spacer()
                view
                Spacer()
            }
        }
        .background {
            Color.white
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 5,
                    x: 0, y: 0
                )
                .mask(Rectangle().padding(.top, -20))
        }
    }

    func needHighlight(_ lineActions: [LineAction]) -> Bool {
        for lineAction in lineActions where lineAction.isHighlighted {
            return true
        }
        return false
    }

    func textContent(lineNum: Int) -> some View {
        VStack {
            if isScrollView {
                ScrollLineView(
                    viewModel: viewModel,
                    codeViewModel: codeViewModel,
                    lineViewModel: codeViewModel.lineViewModels[lineNum],
                    lineNum: lineNum,
                    activeTheme: activeTheme,
                    fontSize: $fontSize
                )
            } else {
                WrapLineView(
                    viewModel: viewModel,
                    codeViewModel: codeViewModel,
                    lineViewModel: codeViewModel.lineViewModels[lineNum],
                    lineNum: lineNum,
                    activeTheme: activeTheme,
                    fontSize: $fontSize
                )
            }
        }
    }

    func line(lineNum: Int, reader: ScrollViewProxy) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if codeViewModel.lineViewModels[lineNum].isShowing {
                let options = codeViewModel.getLineOption(
                    lineNum: lineNum,
                    screenViewModel: viewModel
                )

                let maxLineNumStr = String(codeViewModel.lineViewModels.count)
                let font = UIFont(name: "Courier", size: CGFloat($fontSize.wrappedValue))
                let lineNumWidth = maxLineNumStr.width(for: font)

                Menu(String(lineNum + 1).leftPadding(toLength: maxLineNumStr.count, withPad: " ")) {
                    ForEach(0..<options.count, id: \.self) { pos in
                        if let buttonText = options[pos].text {
                            Button(buttonText, action: {
                                options[pos].action(viewModel, codeViewModel, lineNum)
                                codeViewModel.setLineAction(lineAction: options[pos])
                            })
                        }
                    }
                }
                .foregroundColor(needHighlight(options) ? .orange : .black)
                .font(Font.custom("Courier", size: CGFloat($fontSize.wrappedValue)))
                .frame(width: lineNumWidth)
                .padding(.vertical, 4)
                .padding(.leading, 7)
                .padding(.trailing, 3)
                .background(Color(white: 0.90))

                textContent(lineNum: lineNum)
                    .frame(height: " ".height(for: font))
                    .padding(.leading, 9)
                    .padding(.vertical, 4)
                    .background(Color(white: lineNum.isMultiple(of: 2) ? 1 : 0.99))
            }
        }
        .id(lineNum)
        .onAppear {
            if let scrollTo = codeViewModel.scrollTo {
                withAnimation { reader.scrollTo(scrollTo, anchor: .top) }
                codeViewModel.resetScroll()
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack(spacing: 0) {
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
                pluginHeader(pluginView.id(UUID()))
            }

            if let action = codeViewModel.activeTokenAction, let pluginView = action.pluginView {
                pluginHeader(pluginView.id(UUID()))
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
            isScrollView: $bool,
            activeTheme: OneLightTheme()
        ).previewInterfaceOrientation(.portrait)
    }
}
