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
    @Environment(\.managedObjectContext) private var viewContext
    @State var repo: Repo?

    var body: some View {
        ZStack {
            if let repo = repo {
                ScreenView(repo: repo)
            }
        }
        .onAppear {
            let api = GitHubApi()
            // swiftlint:disable force_try
            let storage: Storage<GitHubCacheKey, String> = try! Storage(
                diskConfig: GitHubCachedDataFetcherFactory.DefaultCacheDiskConfig,
                memoryConfig: GitHubCachedDataFetcherFactory.DefaultCacheMemoryConfig,
                transformer: TransformerFactory.forCodable(ofType: String.self)
            )

            let client = GitHubClient(
                gitHubApi: api,
                cachedDataFetcherFactory: GitHubCachedDataFetcherFactory(storage: storage)
            )
            Task {
                self.repo = try? await client.getRepository(owner: "hashicorp", name: "terraform")
                    .asyncMap({ gitRepo in
                        await Parser.parse(gitRepo: gitRepo)
                    }).get()
                print(repo)
            }
        }

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
