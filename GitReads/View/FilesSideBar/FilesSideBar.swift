//
//  FilesSideBar.swift
//  GitReads

import SwiftUI

struct FilesSideBar: View {
    let rootDirectoryViewModel: DirectoryBarViewModel
    let closeSideBar: () -> Void

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
                ForEach(rootDirectoryViewModel.directories, id: \.path) { vm in
                    DirectoryBarView(viewModel: vm)
                }

                ForEach(rootDirectoryViewModel.files, id: \.file.path) { vm in
                    FileBarView(viewModel: vm)

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
            rootDirectoryViewModel: DirectoryBarViewModel(directory: MOCK_ROOT_DIRECTORY),
            closeSideBar: { })
    }
}
