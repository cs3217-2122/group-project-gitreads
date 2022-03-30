//
//  FilesSideBar.swift
//  GitReads

import SwiftUI

struct FilesSideBar: View {
    @ObservedObject var viewModel: FilesSideBarViewModel
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
            SearchBarView(searchText: $viewModel.filterText, prompt: "Filter by name")
            List {
                ForEach(viewModel.rootDirectory.directories, id: \.path) { vm in
                    DirectoryBarView(viewModel: vm)
                }

                ForEach(viewModel.rootDirectory.files, id: \.file.path) { vm in
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
            viewModel: FilesSideBarViewModel(repo: Repo(root: MOCK_ROOT_DIRECTORY)),
            closeSideBar: { })
    }
}
