//
//  DirectoryBarView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct DirectoryBarView: View {
    let directory: Directory
    let onSelectFile: (File) -> Void
    @State var opened = false

    var body: some View {
        HStack {
            Image(systemName: opened ? "folder" : "folder.fill")
            Text(directory.name)
        }
        .onTapGesture {
            opened.toggle()
        }

        if opened {
            Group {
                ForEach(directory.directories, id: \.path) { dir in
                    DirectoryBarView(directory: dir, onSelectFile: onSelectFile)
                }

                ForEach(directory.files, id: \.path) { file in
                    FileBarView(file: file, onSelectFile: onSelectFile)
                }
            }
            .padding(.leading, 10)
            .onAppear {
                for file in directory.files {
                    // the user has opened this directory and thus is likely to click
                    // on the files within, so we preload them
                    file.lines.preload()
                }
            }
        }

    }
}

struct DirectoryBarView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryBarView(directory: MOCK_DIRECTORY_A, onSelectFile: { _ in })
    }
}
