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
            .foregroundColor(selected ? .black : .gray)
            .frame(width: 100, height: 40)
    }
}

struct WindowView: View {
    let files: [File]
    @Binding var openFile: File?
    @Binding var fontSize: Int
    @Binding var isScrollView: Bool
    let removeFile: (File) -> Void

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(files, id: \.name) { file in
                        TabView(file: file, selected: file == openFile, closeFile: { removeFile(file) })
                            .onTapGesture {
                                openFile = file
                            }

                    }

                }
            }

            if let file = openFile {
                CodeView(file: file, fontSize: $fontSize, isScrollView: $isScrollView)
            } else {
                Text("No open files...")
                    .frame(maxHeight: .infinity)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WindowView_Previews: PreviewProvider {
    @State static var openFile: File? = File(name: "file1.txt", language: .Java, declarations: [], lines: EMPTY_LINES)
    @State static var fontSize = 25
    @State static var isScrollView = true
    static var previews: some View {
        var files = [
            File(name: "file1.txt", language: .Java, declarations: [], lines: EMPTY_LINES),
            File(name: "file2.txt", language: .Java, declarations: [], lines: EMPTY_LINES),
            File(name: "file3.txt", language: .Java, declarations: [], lines: EMPTY_LINES),
            File(name: "file4.txt", language: .Java, declarations: [], lines: EMPTY_LINES),
            File(name: "file5.txt", language: .Java, declarations: [], lines: EMPTY_LINES)
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
