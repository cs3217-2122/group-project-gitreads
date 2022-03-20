//
//  ScreenView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel = ScreenViewModel()
    @State var loading = true

    let repoFetcher: () async -> Result<Repo, Error>

    init(repoFetcher: @escaping () async -> Result<Repo, Error>) {
        self.repoFetcher = repoFetcher
    }

    var body: some View {
        ZStack {
            if let repo = viewModel.repository {
                repoView(repo: repo)
            }
            if loading {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                let repo = await self.repoFetcher()
                loading = false
                // TODO: handle errors
                if case let .success(repo) = repo {
                    viewModel.setRepo(repo)
                }
            }
        }
    }

    func repoView(repo: Repo) -> some View {
        HStack {
            if viewModel.showSideBar {
                FilesSideBar(
                    rootDirectory: repo.root,
                    closeSideBar: viewModel.toggleSideBar,
                    onSelectFile: { file in
                        viewModel.openFile(file: file)
                    })
            }
            NavigationView {
                VStack {
                    WindowView(
                        files: viewModel.files,
                        openFile: $viewModel.openFile,
                        removeFile: { file in
                            viewModel.removeFile(file: file)
                        })
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "book")
                            .foregroundColor(.accentColor)
                            .onTapGesture(perform: viewModel.toggleSideBar)
                    }
                }

            }
        }
    }
}

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenView(repoFetcher: { .success(Repo(root: MOCK_ROOT_DIRECTORY)) })
    }
}
