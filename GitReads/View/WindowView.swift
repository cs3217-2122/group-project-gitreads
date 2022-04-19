//
//  WindowView.swift
//  GitReads

import SwiftUI

struct TabView: View {
    let file: File
    let selected: Bool
    let closeFile: () -> Void
    @StateObject var viewModel: ScreenViewModel
    @StateObject var codeViewModel: CodeViewModel

    var body: some View {
        HStack {
            if !codeViewModel.lineViewModels.isEmpty {
                let options = codeViewModel.getFileOption(
                    screenViewModel: viewModel
                )
                Text(file.name).contextMenu {
                    ForEach(0..<options.count, id: \.self) { pos in
                        if let buttonText = options[pos].text {
                            Button(buttonText, action: {
                                options[pos].action(viewModel, codeViewModel)
                                codeViewModel.setFileAction(fileAction: options[pos])
                            })
                        }
                    }
                }
            }

            if selected {
                Image(systemName: "xmark")
                    .onTapGesture(perform: closeFile)

            }
        }
        .padding(1)
        .foregroundColor(selected ? .black : .gray)
        .frame(width: 100, height: 40)
        .background {
            if selected {
                Rectangle()
                    .fill(.gray)
                    .opacity(0.2)
                    .cornerRadius(3, corners: [.topLeft, .topRight])
            }
        }
    }
}

struct WindowView: View {
    @StateObject var viewModel: ScreenViewModel
    @Binding var openFile: CodeViewModel?
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool

    let activeTheme: Theme
    let removeFile: (File) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.codeViewModels, id: \.file) { codeViewModel in
                        TabView(
                            file: codeViewModel.file,
                            selected: codeViewModel == openFile,
                            closeFile: { removeFile(codeViewModel.file) },
                            viewModel: viewModel,
                            codeViewModel: codeViewModel
                        ).onTapGesture {
                            openFile = codeViewModel
                        }
                    }

                }
            }
            Divider()
            ZStack {
                ForEach(viewModel.codeViewModels, id: \.file) { codeViewModel in
                    CodeView(
                        viewModel: viewModel,
                        codeViewModel: codeViewModel,
                        fontSize: $fontSize,
                        isScrollView: $isScrollView,
                        activeTheme: activeTheme
                    ).opacity(codeViewModel == openFile ? 1 : 0)
                }
            }

            if openFile == nil {
                Text("No open files...")
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WindowView_Previews: PreviewProvider {
    @State static var openFile: CodeViewModel? = CodeViewModel(
        file: File(
            path: Path(components: "file1.txt"),
            sha: "deadbeef",
            language: .others,
            parseOutput: EMPTY_PARSE_OUTPUT
        ))

    @State static var fontSize = 25
    @State static var isScrollView = true

    static var previews: some View {
        var files = [
            File(path: Path(components: "file1.txt"),
                 sha: "deadbeef",
                 language: .others,
                 parseOutput: EMPTY_PARSE_OUTPUT),
            File(path: Path(components: "file2.txt"),
                 sha: "deadbeef",
                 language: .others,
                 parseOutput: EMPTY_PARSE_OUTPUT),
            File(path: Path(components: "file3.txt"),
                 sha: "deadbeef",
                 language: .others,
                 parseOutput: EMPTY_PARSE_OUTPUT),
            File(path: Path(components: "file4.txt"),
                 sha: "deadbeef",
                 language: .others,
                 parseOutput: EMPTY_PARSE_OUTPUT),
            File(path: Path(components: "file5.txt"),
                 sha: "deadbeef",
                 language: .others,
                 parseOutput: EMPTY_PARSE_OUTPUT)
        ]
            .map { CodeViewModel(file: $0) }
        return WindowView(
            viewModel: ScreenViewModel(),
            openFile: $openFile,
            fontSize: $fontSize,
            isScrollView: $isScrollView,
            activeTheme: OneLightTheme(),
            removeFile: { file in
                files = files.filter({ vm in
                    vm.file != file
                })
            })
    }
}
