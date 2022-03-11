//
//  GitRepo.swift
//  GitReads

struct GitRepo {
    let fullName: String
    let htmlUrl: String
    let description: String

    let defaultBranch: String
    let branches: [String]

    var rootDir: GitDirectory
}
