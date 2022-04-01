//
//  AdvancedSearchView.swift
//  GitReads

import SwiftUI

struct AdvancedSearchView: View {
    @StateObject var viewModel: AdvancedSearchViewModel
    let onSelectOption: (FileNavigateOption) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.options, id: \.self) { option in
                    NavigationOptionView(searchTerm: viewModel.searchText, option: option)
                        .onTapGesture {
                            onSelectOption(option)
                        }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search by file text")
            .navigationTitle("Advanced Search")
        }
        .navigationViewStyle(.stack)
    }
}

struct AdvancedSearchView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSearchView(
            viewModel: AdvancedSearchViewModel(repo: Repo(
                name: "test",
                owner: "djisktra123",
                description: "test repo",
                platform: .github,
                defaultBranch: "main",
                branches: ["main"],
                currBranch: "main",
                root: MOCK_ROOT_DIRECTORY
            )),
            onSelectOption: { _ in })
    }
}
