//
//  FileNavigateOption.swift
//  GitReads

import Foundation

// Models a potential navigation to a file
struct FileNavigateOption {
    let file: File
    let line: Int
    let preview: String

    init(file: File, line: Int = 0, preview: String = "") {
        self.file = file
        self.line = line
        self.preview = preview
    }
}

extension FileNavigateOption: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(line)
        hasher.combine(preview)
    }
}
