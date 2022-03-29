//
//  DirectoryBarView.swift
//  GitReads

import SwiftUI

struct DirectoryBarView: View {
    @ObservedObject var viewModel: DirectoryBarViewModel

    var body: some View {
        HStack {
            Image(systemName: viewModel.isOpen ? "folder" : "folder.fill")
            Text(viewModel.name)
        }
        .onTapGesture {
            viewModel.isOpen.toggle()
        }

        if viewModel.isOpen {
            Group {
                ForEach(viewModel.directories, id: \.path) { vm in
                    DirectoryBarView(viewModel: vm)
                }

                ForEach(viewModel.files, id: \.file.path) { vm in
                    FileBarView(viewModel: vm)
                }
            }
            .padding(.leading, 10)
            .onAppear {
                viewModel.directory.preloadFiles()
            }
        }

    }
}

struct DirectoryBarView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryBarView(viewModel: DirectoryBarViewModel(directory: MOCK_DIRECTORY_A))
    }
}
