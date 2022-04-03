//
//  PreloadVisitor.swift
//  GitReads

import Foundation

private let DEFAULT_PRELOAD_CHUNK_SIZE: Int = 24

class PreloadVisitor: RepoVisitor {
    private var files: [String: File] = [:]
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
        files[file.sha] = file
    }

    func preload() -> Task<(), Error> {
        let preloadTask: Task<(), Error> = Task(priority: .low) {
            var loaded = 0
            let files = Array(self.files.values)

            for chunk in files.chunked(into: self.chunkSize) {
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

                loaded += self.chunkSize
            }
        }

        self.task = preloadTask
        return preloadTask
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
