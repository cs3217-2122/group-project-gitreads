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
                ForEach(directory.directories, id: \.name) { dir in

                    DirectoryBarView(directory: dir, onSelectFile: onSelectFile)
                }

                ForEach(directory.files, id: \.name) { file in
                    FileBarView(file: file, onSelectFile: onSelectFile)
                }
            }
            .padding(.leading, 10)

        }

    }
}

struct DirectoryBarView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryBarView(directory: MOCK_DIRECTORY_A, onSelectFile: { _ in })
    }
}
