//
//  PreloadVisitor.swift
//  GitReads

import Foundation

class PreloadVisitor: RepoVisitor {
    var files: [File] = []
    private var task: Task<(), Error>?
    func visit(directory: Directory) {}

    func visit(file: File) {
        files.append(file)
    }

    func preload() {
        task = Task {
            while !files.isEmpty {
                if Task.isCancelled {
                    return
                }
                let file = files.popLast()
                _ = await file?.lines.value
            }
        }
    }

    func stop() {
        self.task?.cancel()
    }
}
