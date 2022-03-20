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

    let gitClient: GitClient

    init() {
        let api = GitHubApi()
        // swiftlint:disable force_try
        let storage: Storage<GitHubCacheKey, String> = try! Storage(
            diskConfig: GitHubCachedDataFetcherFactory.DefaultCacheDiskConfig,
            memoryConfig: GitHubCachedDataFetcherFactory.DefaultCacheMemoryConfig,
            transformer: TransformerFactory.forCodable(ofType: String.self)
        )

        self.gitClient = GitHubClient(
            gitHubApi: api,
            cachedDataFetcherFactory: GitHubCachedDataFetcherFactory(storage: storage)
        )
    }

    var body: some View {
        ZStack {
            RepoSearchView(gitClient: gitClient)
//            NavigationView {
//                ScreenView {
//                    await gitClient
//                        .getRepository(owner: "kornelski", name: "pngquant")
//                        .asyncFlatMap { await Parser.parse(gitRepo: $0) }
//                }
//                .navigationBarTitle("", displayMode: .inline)
//                .navigationBarHidden(true)
//            }
//            .navigationViewStyle(.stack)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
