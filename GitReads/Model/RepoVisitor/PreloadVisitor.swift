//
//  PreloadVisitor.swift
//  GitReads

import Foundation

private let DEFAULT_PRELOAD_CHUNK_SIZE: Int = 16

class PreloadVisitor: RepoVisitor {
    private var files: [File] = []
    private let chunkSize: Int

    var count: Int {
        self.files.count
    }

    init(chunkSize: Int = DEFAULT_PRELOAD_CHUNK_SIZE) {
        self.chunkSize = chunkSize
    }

    func visit(directory: Directory) {}

    func visit(file: File) {
        files.append(file)
    }

    func afterVisit() -> Preloader {
        Preloader(files: files, chunkSize: chunkSize)
    }
}

class Preloader {
    let totalFiles: Int
    private(set) var filesLoaded: Int
    private let filesToLoad: [File]
    private let chunkSize: Int
    private var task: Task<(), Error>?

    init(files: [File], chunkSize: Int) {
        self.totalFiles = files.count
        self.filesLoaded = 0
        self.filesToLoad = files
        self.chunkSize = chunkSize
    }

    func preload() {
        if let task = task {
            task.cancel()
        }

        task = Task {
            for chunk in self.filesToLoad.chunked(into: self.chunkSize) {
                if Task.isCancelled {
                    return
                }

                await withTaskGroup(of: Void.self) { group in
                    for file in chunk {
                        group.addTask {
                            _ = await file.lines.value
                        }
                    }
                }

                self.filesLoaded += chunk.count
            }
        }
    }

    func cancel() {
        task?.cancel()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
