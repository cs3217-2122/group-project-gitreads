//
//  ScreenViewModel.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import Combine
import SwiftUI

class ScreenViewModel: ObservableObject {
    @Published private(set) var repository = Repo(root: MOCK_ROOT_DIRECTORY)
    @Published private(set) var showSideBar = false
    @Published private(set) var files: [File] = []
    @Published var openFile: File?

    func toggleSideBar() {
        withAnimation {
            showSideBar.toggle()
        }
    }

    func openFile(file: File) {
        if !files.contains(file) {
            files.append(file)
        }
        openFile = file
    }

    func removeFile(file: File) {
        files = files.filter({ f in
            f != file
        })
        if openFile == file {
            openFile = files.first
        }
    }
}
