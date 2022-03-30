//
//  ScreenViewModel.swift
//  GitReads

import Combine
import SwiftUI

class ScreenViewModel: ObservableObject {
    @Published private(set) var repository: Repo?
    @Published private(set) var showSideBar = false
    @Published private(set) var files: [File] = []
    @Published var openFile: File?
    private var preloader: PreloadVisitor?

    func setRepo(_ repo: Repo) {
        self.repository = repo
        self.preload()
    }

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

    func cleanUp() {
        self.preloader?.stop()
    }

    private func preload() {
        self.preloader = PreloadVisitor()
        if let preloader = preloader {
            self.repository?.accept(visitor: preloader)
            preloader.preload()
        }
    }

}

extension ScreenViewModel: FileNavigateDelegate {
    func navigateTo(_ option: FileNavigateOption) {
        openFile(file: option.file)
    }
}
