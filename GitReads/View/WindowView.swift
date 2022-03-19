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
                CodeView(file: file, fontSize: $fontSize)
            } else {
                Text("No open files...")
                    .frame(maxHeight: .infinity)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WindowView_Previews: PreviewProvider {
    @State static var openFile: File? = File(name: "file1.txt", language: "", declarations: [], lines: [])
    @State static var fontSize = 25
    static var previews: some View {
        var files = [
            File(name: "file1.txt", language: "", declarations: [], lines: []),
            File(name: "file2.txt", language: "", declarations: [], lines: []),
            File(name: "file3.txt", language: "", declarations: [], lines: []),
            File(name: "file4.txt", language: "", declarations: [], lines: []),
            File(name: "file5.txt", language: "", declarations: [], lines: [])
        ]
        return WindowView(
            files: files,
            openFile: $openFile,
            fontSize: $fontSize,
            removeFile: { file in
                files = files.filter({ f in
                    f != file
                })
            })
    }
}
