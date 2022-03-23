//
//  FileBarViewModel.swift
//  GitReads

import Foundation

class FileBarViewModel: ObservableObject {
    let file: File
    private weak var delegate: SideBarSelectionDelegate?

    init(file: File) {
        self.file = file
    }

    func setDelegate(delegate: SideBarSelectionDelegate) {
        self.delegate = delegate
    }

    func onSelectFile() {
        self.delegate?.onSelectFile(file)
    }
}
