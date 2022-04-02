//
//  ContentView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import SwiftUI
import CoreData
import Cache

struct ContentView: View {
    @State var repo: Repo?

    let gitClient: GitClient
    let repoService: RepoService

    init() {
        let api = GitHubApi()
        let factory = GitHubCachedDataFetcherFactory()
        if factory == nil {
            print("Failed to initialize cache for git client")
        }

        self.gitClient = GitHubClient(gitHubApi: api, cachedDataFetcherFactory: factory)

        let parser = Parser()
        self.repoService = RepoService(gitClient: gitClient, parser: parser)
    }

    var body: some View {
        ZStack {
            HomeView(repoService: repoService)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
