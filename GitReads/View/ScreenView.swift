//
//  ScreenView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel = ScreenViewModel()
    @StateObject var settings = SettingViewModel()
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
            VStack {
                HStack {
                    Button(action: viewModel.toggleSideBar, label: {
                        Image(systemName: "book")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.accentColor)
                            .padding(.leading)
                    })
                    Spacer()
                    Button(action: settings.toggleSideBar, label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.accentColor)
                            .padding(.trailing)
                        })
                }
                NavigationView {
                    WindowView(
                        files: viewModel.files,
                        openFile: $viewModel.openFile,
                        fontSize: $settings.fontSize,
                        isScrollView: $settings.isScrollView,
                        removeFile: { file in
                        viewModel.removeFile(file: file)
                        })
                    .navigationBarHidden(true)
                }
                .onTapGesture {
                    if viewModel.showSideBar {
                        viewModel.hideSideBar()
                    }
                    if settings.showSideBar {
                        settings.hideSideBar()
                    }
                }
            }
            if settings.showSideBar {
                SettingView(closeSideBar: settings.toggleSideBar,
                            increaseSize: settings.increaseSize,
                            decreaseSize: settings.decreaseSize,
                            isScrollView: $settings.isScrollView,
                            size: settings.fontSize)
            }
        }
    }
}

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenView(repoFetcher: { .success(Repo(root: MOCK_ROOT_DIRECTORY)) })
    }
}
