//
//  FileNavigateOption.swift
//  GitReads

import Foundation

// Models a potential navigation to a file
struct FileNavigateOption {
    let file: File
    let line: Int
    let preview: String
}
