//
//  FileNameSearchVisitor.swift
//  GitReads

import Foundation

class FileNameSearchVisitor: RepoVisitor {
    private let searchText: String
    private var directories: [Path] = []
    private var innerFiles: [[File]] = []
    private var innerDirs: [[Directory]] = []
    private var rootDirectory: Directory?

    init(searchText: String) {
        self.searchText = searchText
    }

    func visit(directory: Directory) {
        directories.append(directory.path)
        innerFiles.append([])
        innerDirs.append([])
    }

    func visit(file: File) {
        if file.path.string.contains(searchText) || searchText.isEmpty {
            innerFiles[innerFiles.endIndex.advanced(by: -1)].append(file)
        }
    }

    func afterVisit(directory: Directory) {
        guard let path = directories.popLast(),
           let files = innerFiles.popLast(),
           let dirs = innerDirs.popLast() else {
            return
        }

        if directories.isEmpty {
            rootDirectory = Directory(files: files, directories: dirs, path: path)
        } else if !files.isEmpty || !dirs.isEmpty {
            innerDirs[innerDirs.endIndex.advanced(by: -1)]
                .append(Directory(files: files, directories: dirs, path: path))
        }

    }

    func afterVisit() -> Directory {
        rootDirectory ?? Directory(files: [], directories: [], path: .root)
    }
}
