//
//  RepoSearchView.swift
//  GitReads

import SwiftUI

struct RepoSearchView: View {

    @StateObject private var viewModel: RepoSearchViewModel

    let gitClient: GitClient

    init(gitClient: GitClient) {
        self.gitClient = gitClient
        _viewModel = StateObject(wrappedValue: RepoSearchViewModel(gitClient: gitClient))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.repos, id: \.fullName) { repo in
                    repoSummary(repo)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search for a repo")
            .navigationTitle("Repo Search")
        }
        .navigationViewStyle(.stack)
    }

    func repoSummary(_ repo: GitRepoSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            let fetcher = repoFetcherFor(owner: repo.owner, name: repo.name)
            let screenView = ScreenView(repoFetcher: fetcher)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)

            NavigationLink(destination: screenView) {
                Text(repo.fullName)
                    .font(.headline)
            }
            if !repo.description.isEmpty {
                Text(repo.description)
                    .fontWeight(.light)
                    .font(.caption)
                    .lineLimit(3)
            }
        }
        .padding()
    }

    func repoFetcherFor(owner: String, name: String) -> (() async -> Result<Repo, Error>) {
        {
            await gitClient
                .getRepository(owner: owner, name: name)
                .asyncFlatMap { await Parser.parse(gitRepo: $0) }
        }
    }
}
