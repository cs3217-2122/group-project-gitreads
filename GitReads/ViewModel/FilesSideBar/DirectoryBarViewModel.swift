//
//  DirectoryBarViewModel.swift
//  GitReads

import Foundation

class DirectoryBarViewModel: ObservableObject {
    @Published var isOpen: Bool
    @Published private(set) var directories: [DirectoryBarViewModel]
    @Published private(set) var files: [FileBarViewModel]

    let directory: Directory
    let name: String

    var path: Path {
        directory.path
    }

    init(directory: Directory, isOpen: Bool = false) {
        var directory = directory
        var name = ""
        while directory.directories.count == 1 && directory.files.isEmpty {
            name += directory.name + "/"
            directory = directory.directories[0]
        }
        self.directory = directory
        self.name = name + self.directory.name
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
