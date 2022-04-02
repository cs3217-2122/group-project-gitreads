//  MockDelegate.swift
//  GitReadsTests

import Foundation
@testable import GitReads

 class MockDelegate: FileNavigateDelegate {
    private(set) var count = 0
    private(set) var files = [File]()

     func navigateTo(_ option: FileNavigateOption) {
         count += 1
         files.append(option.file)
    }
 }
