//
//  FileBarViewModel.swift
//  GitReads

import Foundation

class FileBarViewModel: ObservableObject {
    let file: File
    private weak var delegate: FileNavigateDelegate?

    init(file: File) {
        self.file = file
    }

    func setDelegate(delegate: FileNavigateDelegate) {
        self.delegate = delegate
    }

    func onSelectFile() {
        self.delegate?.navigateTo(FileNavigateOption(file: file))
    }
}
