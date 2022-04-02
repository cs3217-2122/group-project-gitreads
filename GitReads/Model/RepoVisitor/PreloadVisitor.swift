//
//  PreloadVisitor.swift
//  GitReads

import Foundation

private let DEFAULT_PRELOAD_CHUNK_SIZE: Int = 16

class PreloadVisitor: RepoVisitor {
    private var files: [File] = []
    private var task: Task<(), Error>?
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

    func preload() {
        task = Task(priority: .low) {
            for chunk in self.files.chunked(into: self.chunkSize) {
                if Task.isCancelled {
                    return
                }

                await withTaskGroup(of: Void.self) { group in
                    for file in chunk {
                        group.addTask {
                            _ = await file.parseOutput.value
                        }
                    }

                }
            }
        }
    }

    func stop() {
        self.task?.cancel()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
