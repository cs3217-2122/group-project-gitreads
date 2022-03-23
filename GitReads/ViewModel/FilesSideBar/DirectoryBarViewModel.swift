//
//  DirectoryBarViewModel.swift
//  GitReads

import Foundation

class DirectoryBarViewModel: ObservableObject {
    @Published var isOpen: Bool
    @Published private(set) var directories: [DirectoryBarViewModel]
    @Published private(set) var files: [FileBarViewModel]

    let name: String
    let path: Path

    init(directory: Directory) {
        self.name = directory.name
        self.path = directory.path
        self.isOpen = false
        self.directories = directory.directories.map { DirectoryBarViewModel(directory: $0) }
        self.files = directory.files.map { FileBarViewModel(file: $0) }
    }

    func setDelegate(delegate: SideBarSelectionDelegate) {
        self.directories.forEach { $0.setDelegate(delegate: delegate) }
        self.files.forEach { $0.setDelegate(delegate: delegate) }
    }
}
