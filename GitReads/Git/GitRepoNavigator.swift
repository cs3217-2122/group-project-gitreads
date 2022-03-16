//
//  GitRepoNavigator.swift
//  GitReads

protocol GitRepoNavigator {
    var owner: String { get }
    var repoName: String { get }

    var currentBranch: String { get }
    var rootDir: GitDirectory? { get }

    func contentsAt(path: Path) async -> Result<GitContent, Error>
    func withBranch(_ branch: String) -> GitRepoNavigator
}
