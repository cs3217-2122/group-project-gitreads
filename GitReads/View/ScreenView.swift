//
//  ScreenView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel: ScreenViewModel
    @StateObject var settings: SettingViewModel

    init(repo: Repo) {
        _viewModel = StateObject(wrappedValue: ScreenViewModel(repo: repo))
        _settings = StateObject(wrappedValue: SettingViewModel())
    }

    var body: some View {
        HStack {
            if viewModel.showSideBar {
                FilesSideBar(
                    rootDirectory: viewModel.repository.root,
                    closeSideBar: viewModel.toggleSideBar,
                    onSelectFile: { file in
                        viewModel.openFile(file: file)
                    })
            }
            NavigationView {
                VStack {
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(.accentColor)
                            .onTapGesture(perform: viewModel.toggleSideBar)
                            .padding(.leading)
                        Spacer()
                        Image(systemName: "gearshape")
                            .foregroundColor(.accentColor)
                            .onTapGesture(perform: settings.toggleSideBar)
                            .padding(.trailing)
                    }
                    WindowView(
                        files: viewModel.files,
                        openFile: $viewModel.openFile,
                        removeFile: { file in
                            viewModel.removeFile(file: file)
                        })
                }
                .navigationBarHidden(true)
            }
            .onTapGesture {
                if viewModel.showSideBar {
                    viewModel.toggleSideBar()
                } else if settings.showSideBar {
                    settings.toggleSideBar()
                }
            }
            if settings.showSideBar {
                SettingView(closeSideBar: settings.toggleSideBar,
                            increaseSize: settings.increaseSize,
                            decreaseSize: settings.decreaseSize,
                            size: settings.fontSize)
            }
        }
    }
}

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenView(repo: Repo(root: MOCK_ROOT_DIRECTORY))
    }
}
