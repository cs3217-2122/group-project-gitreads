//
//  FilesSideBarViewModel.swift
//  GitReads

import Foundation
import Combine

class FilesSideBarViewModel: ObservableObject {
    @Published var filterText: String = ""
    @Published var rootDirectory: DirectoryBarViewModel

    let repo: Repo
    private weak var delegate: FileNavigateDelegate?
    private let originalRootDirectory: DirectoryBarViewModel
    private var subscriptions: Set<AnyCancellable> = []

    init(repo: Repo) {
        self.repo = repo
        self.originalRootDirectory = DirectoryBarViewModel(directory: repo.root)
        self.rootDirectory = originalRootDirectory

        $filterText
            .map { $0.lowercased() }
            .sink { self.rootDirectory = self.search($0) }.store(in: &subscriptions)
    }

    func onFileNavigate(option: FileNavigateOption) {
        self.delegate?.navigateTo(option)
    }

    func setDelegate(delegate: FileNavigateDelegate) {
        self.delegate = delegate
        self.originalRootDirectory.setDelegate(delegate: delegate)
        self.rootDirectory.setDelegate(delegate: delegate)
    }

    private func search(_ text: String) -> DirectoryBarViewModel {
        if text.isEmpty {
            return originalRootDirectory
        } else {
            let vm = DirectoryBarViewModel(
                directory: repo.accept(visitor: FileNameSearchVisitor(searchText: text)), isOpen: true)
            if let delegate = delegate {
                vm.setDelegate(delegate: delegate)
            }

            return vm
        }
    }
}
