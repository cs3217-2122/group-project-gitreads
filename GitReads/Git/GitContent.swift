//
//  GitContent.swift
//  GitReads

import Foundation

struct GitContent {
    let type: GitContentType

    let name: String
    let path: Path
    let sha: String

    let sizeInBytes: Int
}
