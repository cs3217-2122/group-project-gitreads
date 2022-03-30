//
//  DirectoryBarViewModel.swift
//  GitReads

import Foundation

class DirectoryBarViewModel: ObservableObject {
    @Published var isOpen: Bool
    @Published private(set) var directories: [DirectoryBarViewModel]
    @Published private(set) var files: [FileBarViewModel]

    let directory: Directory

    var name: String {
        directory.name
    }

    var path: Path {
        directory.path
    }

    init(directory: Directory, isOpen: Bool = false) {
        self.directory = directory
        self.isOpen = isOpen
        self.directories = directory.directories.map { DirectoryBarViewModel(directory: $0, isOpen: isOpen) }
        self.files = directory.files.map { FileBarViewModel(file: $0) }
        self.directories.sort { $0.name < $1.name }
        self.files.sort { $0.file.name < $1.file.name }
    }

    func setDelegate(delegate: FileNavigateDelegate) {
        self.directories.forEach { $0.setDelegate(delegate: delegate) }
        self.files.forEach { $0.setDelegate(delegate: delegate) }
    }
}
