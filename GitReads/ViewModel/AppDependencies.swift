//
//  AppDependencies.swift
//  GitReads

import SwiftUI

class AppDependencies: ObservableObject {

    let gitClient: GitClient
    let repoService: RepoService

    init() {
        let api = GitHubApi()
        let githubFetcherFactory = GitHubCachedDataFetcherFactory()
        if githubFetcherFactory == nil {
            print("Failed to initialize cache for github content")
        }

        self.gitClient = GitHubClient(gitHubApi: api, cachedDataFetcherFactory: githubFetcherFactory)

        let linesFetcherFactory = LinesCachedDataFetcherFactory()
        if linesFetcherFactory == nil {
            print("Failed to initialize cache for parser results")
        }

        let parser = Parser(cachedDataFetcherFactory: linesFetcherFactory )
        self.repoService = RepoService(gitClient: gitClient, parser: parser)
    }
}
