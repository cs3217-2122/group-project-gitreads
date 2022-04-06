//
//  ScreenView.swift
//  GitReads

import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel = ScreenViewModel()
    @StateObject var settings = SettingViewModel()
    @State var sideBarViewModel: FilesSideBarViewModel?

    @State var repo: Repo

    init(repo: Repo) {
        self._repo = State(wrappedValue: repo)
    }

    func initializeWithRepo(_ repo: Repo) {
        viewModel.repo = repo
        sideBarViewModel = FilesSideBarViewModel(repo: repo)
        sideBarViewModel?.setDelegate(delegate: viewModel)
    }

    var body: some View {
        ZStack {
            repoView(repo: repo)
        }
        .onAppear {
            initializeWithRepo(repo)
        }
    }

    func repoView(repo: Repo) -> some View {
        HStack {
            if let sideBarViewModel = sideBarViewModel,
               viewModel.showSideBar {
                FilesSideBar(
                    viewModel: sideBarViewModel,
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
                    viewModel: viewModel, // not the ideal case
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
        ScreenView(repo: Repo(
                name: "test",
                owner: "dijkstra123",
                description: "test repo",
                platform: .github,
                defaultBranch: "main",
                branches: ["main"],
                currBranch: "main",
                root: MOCK_ROOT_DIRECTORY
            ))
    }
}
