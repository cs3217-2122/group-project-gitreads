//
//  PreloadVisitor.swift
//  GitReads

import Foundation
import Combine

private let DEFAULT_PRELOAD_CHUNK_SIZE: Int = 24

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
    private(set) var filesLoaded: CurrentValueSubject<Int, Never>

    private let filesToLoad: [File]
    private let chunkSize: Int
    private var task: Task<(), Error>?

    init(files: [File], chunkSize: Int) {
        self.totalFiles = files.count
        self.filesLoaded = CurrentValueSubject(0)

        self.filesToLoad = files
        self.chunkSize = chunkSize
    }

    var result: Result<(), Error>? {
        get async {
            await task?.result
        }
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
                            _ = await file.parseOutput.value
                        }
                    }
                }

                self.filesLoaded.send(self.filesLoaded.value + chunk.count)
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
