//
//  FileBarView.swift
//  GitReads

import SwiftUI

struct FileBarView: View {
    @ObservedObject var viewModel: FileBarViewModel

    var body: some View {
        Text(viewModel.file.name)
            .onTapGesture(perform: viewModel.onSelectFile)
    }
}

struct FileBarView_Previews: PreviewProvider {
    static var previews: some View {
        FileBarView(viewModel: FileBarViewModel(file: MOCK_FILE))
    }
}
