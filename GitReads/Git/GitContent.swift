//
//  GitContent.swift
//  GitReads

import Foundation

struct GitContent {
    let type: GitContentType

    let name: String
    let path: String
    let sha: String
    let htmlURL: URL

    let sizeInBytes: Int
}
