//
//  FilesSideBar.swift
//  GitReads

import SwiftUI

struct FilesSideBar: View {
    @ObservedObject var viewModel: FilesSideBarViewModel
    @State var showAdvancedSearch = false
    let closeSideBar: () -> Void

    func onAdvancedSearch(option: FileNavigateOption) {
        self.viewModel.onFileNavigate(option: option)
        self.closeSideBar()
        showAdvancedSearch = false
    }

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
            NavigationLink("Advanced Search",
                           destination: AdvancedSearchView(
                            viewModel: AdvancedSearchViewModel(repo: viewModel.repo),
                            onSelectOption: onAdvancedSearch),
                           isActive: $showAdvancedSearch)
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
