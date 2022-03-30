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
    private let plugins: [Plugin] = [CommentPlugin()]

    func setRepo(_ repo: Repo) {
        self.repository = repo
        for file in repo.root.files {
            file.lines.preload()
        }
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

    func getLineOption(lineNum: Int) -> [PluginAction] {
        var result: [PluginAction] = []
        for plugin in plugins {
            result.append(plugin.getLineAction(file: openFile, lineNum: lineNum))
        }
        return result
    }
}

extension ScreenViewModel: SideBarSelectionDelegate {
    func onSelectFile(_ file: File) {
        openFile(file: file)
    }
}
