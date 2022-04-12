//
//  ScreenViewModel.swift
//  GitReads

import Combine
import SwiftUI

class ScreenViewModel: ObservableObject {
    @Published private(set) var showSideBar = true
    @Published private(set) var codeViewModels: [CodeViewModel] = []
    @Published var openFile: CodeViewModel?
    private(set) var repo: Repo?

    func setRepo(_ repo: Repo) {
        self.repo = repo
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

    func openFile(file: File, atLine: Int? = 0) {
        let codeViewModel = codeViewModels.first { $0.file == file }
        if let codeViewModel = codeViewModel {
            codeViewModel.setScrollTo(scrollTo: atLine)
            openFile = codeViewModel
        } else {
            let newCodeViewModel = CodeViewModel(file: file)
            if let repo = self.repo {
                newCodeViewModel.addPlugin(DefinitionLookupPlugin(repo: repo))
            }
            codeViewModels.append(newCodeViewModel)
            openFile = newCodeViewModel
            newCodeViewModel.setScrollTo(scrollTo: atLine)
        }
    }

    func removeFile(file: File) {
        codeViewModels = codeViewModels.filter({ vm in
            vm.file != file
        })
        if openFile?.file == file {
            openFile = codeViewModels.first
        }
    }
}

extension ScreenViewModel: FileNavigateDelegate {
    func navigateTo(_ option: FileNavigateOption) {
        openFile(file: option.file, atLine: option.line)
    }
}
