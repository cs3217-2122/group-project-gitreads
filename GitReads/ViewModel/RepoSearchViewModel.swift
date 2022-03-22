//
//  RepoSearchViewModel.swift
//  GitReads

import SwiftUI
import Combine

public class RepoSearchViewModel: ObservableObject {

    // Actor to synchronize the updating of the currentPage of the pagianted search,
    // and the array of search results.
    actor SearchActor {

        private let reposSubject: CurrentValueSubject<[GitRepoSummary], Never>

        var repos: [GitRepoSummary] = []
        // we need a set to remove duplicates, as sometimes the GitHub API returns
        // duplicate entries across multiple pages
        var repoSet: Set<GitRepoSummary> = []

        var currentPage: PaginatedResponse<GitRepoSummary>?
        var searchText: String?

        // The actor uses the subject to publish changes in the current list of seach results
        // back to the View
        init(reposSubject: CurrentValueSubject<[GitRepoSummary], Never>) {
            self.reposSubject = reposSubject
        }

        func resetSearch() {
            repos = []
            repoSet = []
            currentPage = nil
            searchText = nil

            reposSubject.send(repos)
        }

        func setFirstPage(_ page: PaginatedResponse<GitRepoSummary>, searchText: String) {
            repos = page.items
            repoSet = Set(page.items)
            currentPage = page
            self.searchText = searchText

            reposSubject.send(repos)
        }

        func nextPage(searchText: String) async {
            // if the search text has changed, that means the user has typed something
            // into the search bar and we should not fetch any subsequent pages
            if self.searchText != searchText {
                return
            }

            guard let currentPage = currentPage else {
                return
            }

            let result = await currentPage.nextPage()

            // need to check again due to swift actor reentrancy
            if self.searchText != searchText {
                return
            }

            switch result {
            case let .success(nextPage):
                for item in nextPage.items {
                    // skip duplicates
                    if repoSet.contains(item) {
                        continue
                    }

                    repoSet.insert(item)
                    repos.append(item)
                }

                self.currentPage = nextPage

                reposSubject.send(repos)

            case let .failure(err):
                print("Loading next page of search results error: \(err)")
            }
        }
    }

    let gitClient: GitClient

    @Published var searchText: String = ""
    @Published var isSearching = false
    @Published private(set) var repos: [GitRepoSummary] = []

    private let searchActor: SearchActor
    private let reposSubject = CurrentValueSubject<[GitRepoSummary], Never>([])

    private var subscriptions: Set<AnyCancellable> = []

    init(gitClient: GitClient) {
        self.gitClient = gitClient
        self.searchActor = SearchActor(reposSubject: reposSubject)

        // Subscribe to the publisher for any changes in the search results
        reposSubject
            .receive(on: DispatchQueue.main)
            .sink { repos in
                self.repos = repos
            }
            .store(in: &subscriptions)

        // Debounce any changes to the search text, then do a search via the git client
        // for any non-empty search texts
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .asyncMap { text -> (result: Result<PaginatedResponse<GitRepoSummary>, Error>, text: String)? in
                if text.isEmpty {
                    Task {
                        await self.searchActor.resetSearch()
                    }
                    return nil
                }

                self.setIsSearching(true)
                let result = await self.gitClient.searchRepositories(query: text)
                self.setIsSearching(false)

                return (result: result, text: text)
            }
            .compactMap { $0 } // remove nil values
            .sink { results, text in
                switch results {
                case let .success(paginatedRepos):
                    Task {
                        await self.searchActor.setFirstPage(paginatedRepos, searchText: text)
                    }
                case let .failure(err):
                    print("Searching repos error: \(err)")
                }
            }
            .store(in: &subscriptions)
    }

    func scrolledToItem(repo: GitRepoSummary) {
        // only load the next page when 3 items away from the end of the list
        let thresholdIndex = repos.index(repos.endIndex, offsetBy: -4)
        if repos.firstIndex(where: { $0.fullName == repo.fullName }) != thresholdIndex {
            return
        }

        Task {
            self.setIsSearching(true)
            await searchActor.nextPage(searchText: self.searchText)
            self.setIsSearching(false)
        }
    }

    func setIsSearching(_ value: Bool) {
        DispatchQueue.main.async { self.isSearching = value }
    }
}
