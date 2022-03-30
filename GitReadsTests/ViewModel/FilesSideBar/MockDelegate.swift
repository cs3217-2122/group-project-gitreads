//  MockDelegate.swift
//  GitReadsTests

import Foundation
@testable import GitReads

class MockDelegate: FileNavigateDelegate {
    private(set) var count = 0
    private(set) var files = [File]()

    func onSelectFile(_ file: File) {
        count += 1
        files.append(file)
    }
}
