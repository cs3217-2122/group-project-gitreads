//
//  WindowView.swift
//  GitReads

import SwiftUI

struct TabView: View {
    let file: File
    let selected: Bool
    let closeFile: () -> Void

    var body: some View {
        HStack {
            Text(file.name)

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
    let codeViewModels: [CodeViewModel]
    @StateObject var viewModel: ScreenViewModel
    @Binding var openFile: CodeViewModel?
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool
    let removeFile: (File) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(codeViewModels, id: \.file) { codeViewModel in
                        TabView(
                            file: codeViewModel.file,
                            selected: codeViewModel == openFile,
                            closeFile: { removeFile(codeViewModel.file) })
                            .onTapGesture {
                                openFile = codeViewModel
                            }
                    }

                }
            }
            Divider()
            ZStack {
                ForEach(codeViewModels, id: \.file) { codeViewModel in
                    CodeView(
                        viewModel: viewModel,
                        codeViewModel: codeViewModel,
                        fontSize: $fontSize,
                        isScrollView: $isScrollView
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
            codeViewModels: files,
            viewModel: ScreenViewModel(),
            openFile: $openFile,
            fontSize: $fontSize,
            isScrollView: $isScrollView,
            removeFile: { file in
                files = files.filter({ vm in
                    vm.file != file
                })
            })
    }
}
