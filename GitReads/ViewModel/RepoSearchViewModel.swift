//
//  RepoSearchViewModel.swift
//  GitReads

import SwiftUI
import Combine

public class RepoSearchViewModel: ObservableObject {
    let gitClient: GitClient

    @Published var searchText: String = ""
    @Published var isSearching = false
    @Published private(set) var repos: [GitRepoSummary] = []

    private var subscriptions: Set<AnyCancellable> = []

    init(gitClient: GitClient) {
        self.gitClient = gitClient
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .asyncMap { text -> Result<[GitRepoSummary], Error>? in
                if text.isEmpty {
                    DispatchQueue.main.async { self.repos = [] }
                    return nil
                }

                DispatchQueue.main.async { self.isSearching = true }
                let repos = await self.gitClient.searchRepositories(query: text)
                DispatchQueue.main.async { self.isSearching = false }

                return repos
            }
            .compactMap { $0 } // remove nil values
            .sink { results in
                switch results {
                case let .success(repos):
                    DispatchQueue.main.async { self.repos = repos }
                case let .failure(err):
                    print("Searching repos error: \(err)")
                }
            }
            .store(in: &subscriptions)
    }
}
