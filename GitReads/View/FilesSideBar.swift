//
//  FilesSideBar.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct FilesSideBar: View {
    let rootDirectory: Directory
    let closeSideBar: () -> Void
    let onSelectFile: (File) -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "chevron.left")
                    .padding()
                    .foregroundColor(.accentColor)
                    .onTapGesture(perform: closeSideBar)
            }
            List {
                ForEach(rootDirectory.directories, id: \.path) { dir in
                    DirectoryBarView(directory: dir, onSelectFile: onSelectFile)
                }

                ForEach(rootDirectory.files, id: \.path) { file in
                    FileBarView(file: file, onSelectFile: onSelectFile)

                }
            }
            .listStyle(SidebarListStyle())
            Spacer()
        }
    }
}

struct FilesSideBar_Previews: PreviewProvider {
    static var previews: some View {
        FilesSideBar(
            rootDirectory: MOCK_ROOT_DIRECTORY,
            closeSideBar: { },
            onSelectFile: { _ in })
    }
}
