//
//  ScreenViewModel.swift
//  GitReads

import Combine
import SwiftUI

class ScreenViewModel: ObservableObject {
    @Published private(set) var showSideBar = false
    @Published private(set) var files: [File] = []
    @Published var openFile: File?

    private var preloader: PreloadVisitor?

    func toggleSideBar() {
        withAnimation {
            showSideBar.toggle()
        }
    }

    func hideSideBar() {
        withAnimation {
            showSideBar = false
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

extension ScreenViewModel: FileNavigateDelegate {
    func navigateTo(_ option: FileNavigateOption) {
        openFile(file: option.file)
    }
}
