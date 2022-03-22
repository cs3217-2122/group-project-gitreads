//
//  WindowView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

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
    let files: [File]
    @Binding var openFile: File?
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool
    let removeFile: (File) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(files, id: \.path) { file in
                        TabView(file: file, selected: file == openFile, closeFile: { removeFile(file) })
                            .onTapGesture {
                                openFile = file
                            }
                    }

                }
            }
            Divider()
            ZStack {
                ForEach(files, id: \.path) { file in
                    CodeView(file: file, fontSize: $fontSize, isScrollView: $isScrollView)
                        .opacity(file == openFile ? 1 : 0)
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
    @State static var openFile: File? = File(
        path: Path(components: "file1.txt"),
        language: .Java,
        declarations: [],
        lines: EMPTY_LINES
    )

    @State static var fontSize = 25
    @State static var isScrollView = true
    static var previews: some View {
        var files = [
            File(path: Path(components: "file1.txt"), language: .Java, declarations: [], lines: EMPTY_LINES),
            File(path: Path(components: "file2.txt"), language: .Java, declarations: [], lines: EMPTY_LINES),
            File(path: Path(components: "file3.txt"), language: .Java, declarations: [], lines: EMPTY_LINES),
            File(path: Path(components: "file4.txt"), language: .Java, declarations: [], lines: EMPTY_LINES),
            File(path: Path(components: "file5.txt"), language: .Java, declarations: [], lines: EMPTY_LINES)
        ]
        return WindowView(
            files: files,
            openFile: $openFile,
            fontSize: $fontSize,
            isScrollView: $isScrollView,
            removeFile: { file in
                files = files.filter({ f in
                    f != file
                })
            })
    }
}
