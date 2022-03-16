//
//  ScreenView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel: ScreenViewModel

    init(repo: Repo) {
        _viewModel = StateObject(wrappedValue: ScreenViewModel(repo: repo))
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
        ScreenView(repo: Repo(root: MOCK_ROOT_DIRECTORY))
    }
}
