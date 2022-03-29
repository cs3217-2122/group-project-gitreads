//
//  ScreenView.swift
//  GitReads

import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel = ScreenViewModel()
    @StateObject var settings = SettingViewModel()
    @State var rootDirectoryViewModel: DirectoryBarViewModel?
    @State var loading = true

    let repoFetcher: () async -> Result<Repo, Error>

    init(repoFetcher: @escaping () async -> Result<Repo, Error>) {
        self.repoFetcher = repoFetcher
    }

    func initializeWithRepo(_ repo: Repo) {
        viewModel.setRepo(repo)
        rootDirectoryViewModel = DirectoryBarViewModel(directory: repo.root)
        rootDirectoryViewModel?.setDelegate(delegate: viewModel)
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
                    initializeWithRepo(repo)
                }
            }
        }
        .onDisappear {
            viewModel.cleanUp()
        }
    }

    func repoView(repo: Repo) -> some View {
        HStack {
            if let rootDirectoryViewModel = rootDirectoryViewModel, viewModel.showSideBar {
                FilesSideBar(
                    rootDirectoryViewModel: rootDirectoryViewModel,
                    closeSideBar: viewModel.toggleSideBar)
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
                WindowView(
                    files: viewModel.files,
                    openFile: $viewModel.openFile,
                    fontSize: $settings.fontSize,
                    isScrollView: $settings.isScrollView,
                    removeFile: { file in
                        viewModel.removeFile(file: file)
                    })
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
                settingsView
            }
        }
    }

    var settingsView: some View {
        SettingView(closeSideBar: settings.toggleSideBar,
                    increaseSize: settings.increaseSize,
                    decreaseSize: settings.decreaseSize,
                    isScrollView: $settings.isScrollView,
                    size: settings.fontSize)
    }
}

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenView(repoFetcher: { .success(Repo(root: MOCK_ROOT_DIRECTORY)) })
    }
}
