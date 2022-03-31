//
//  RepoSearchView.swift
//  GitReads

import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel: RepoSearchViewModel

    let gitClient: GitClient

    init(gitClient: GitClient) {
        self.gitClient = gitClient
        _viewModel = StateObject(wrappedValue: RepoSearchViewModel(gitClient: gitClient))
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    if viewModel.isSearching {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    ForEach(viewModel.repos, id: \.fullName) { repo in
                        repoSummary(repo)
                            .onAppear {
                                viewModel.scrolledToItem(repo: repo)
                            }
                    }
                }

            }
            .navigationTitle("Home")
            .overlay {
                FavouritesView(gitClient: gitClient)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search for a repo")
        .navigationViewStyle(.stack)
    }

    func repoSummary(_ repo: GitRepoSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            let fetcher = repoFetcherFor(gitClient: gitClient, owner: repo.owner, name: repo.name)
            let repoView = RepoHomePageView(repoFetcher: fetcher)
                .navigationBarTitle("", displayMode: .inline)

            NavigationLink(destination: repoView) {
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
}

func repoFetcherFor(
    gitClient: GitClient,
    owner: String,
    name: String
) -> (() async -> Result<Repo, Error>) {
    {
        await gitClient
            .getRepository(owner: owner, name: name)
            .asyncFlatMap { await Parser.parse(gitRepo: $0) }
    }
}

struct FavouritesView: View {

    @Environment(\.isSearching) var isSearching
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    var favouritedRepos: FetchedResults<FavouritedRepo>

    @State private var selectedRepo: FavouritedRepo?
    @State private var showRepoPage = false

    let gitClient: GitClient

    var favouritesHeader: some View {
        HStack {
            Label {
                Text("Favourites")
                    .font(.title)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    func favouriteItem(idx: Int, repo: FavouritedRepo, numRepos: Int) -> some View {
        let first = idx == 0
        let last = idx == numRepos - 1

        return Group {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(repo.owner ?? "")
                            .fontWeight(.light)
                            .foregroundColor(Color(.darkGray))
                            .padding(.top, 12)
                        Text(repo.name ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 12)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 2)
                }

                if !last {
                    Divider()
                }
            }
            .padding(.horizontal)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .background {
                Rectangle()
                    .fill(.white)
                    .cornerRadius(
                        8,
                        corners: first && last ? .allCorners
                        : first ? [.topLeft, .topRight]
                        : last ? [.bottomLeft, .bottomRight]
                        : []
                    )
            }
            .onTapGesture {
                selectedRepo = repo
                showRepoPage = true
            }
        }
    }

    var favouritesView: some View {
        ScrollView {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selectedRepo = selectedRepo {
                        let fetcher = repoFetcherFor(
                            gitClient: gitClient,
                            owner: selectedRepo.owner ?? "",
                            name: selectedRepo.name ?? ""
                        )

                        let repoView = RepoHomePageView(repoFetcher: fetcher)
                            .navigationBarTitle("", displayMode: .inline)
                        // We must use a hidden navigation link with the isActive argument instead
                        // of a more normal method where the navigation link is embedded in
                        // the view of the repository. This is to avoid the case where the user
                        // unfavourites a repository after he navigated via this navigation link.
                        // With the other method, the fetched results will update and the repository
                        // will be gone from the search results, causing the navigation link for that repo to not be
                        // rendered, and thus forcibly navigating the user back. With this approach, the
                        // navigation link will still exist so the user can continue browsing in peace :)
                        NavigationLink("", destination: repoView, isActive: $showRepoPage).hidden()
                    }

                    let repos = Array(favouritedRepos.enumerated())
                    ForEach(repos, id: \.element.key) { idx, repo in
                        favouriteItem(idx: idx, repo: repo, numRepos: repos.count)
                    }

                    if favouritedRepos.isEmpty {
                        HStack {
                            Spacer()
                            Text("You have no favourited repositories 😅")
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.vertical, 24)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray6))
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                Spacer()
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
        }
    }

    var body: some View {
        if !isSearching {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    VStack {
                        favouritesHeader
                        favouritesView
                            .padding(.bottom, 24)
                    }
                    .padding()
                    .background {
                        Rectangle()
                            .fill(.white)
                            .cornerRadius(32, corners: [.topLeft, .topRight])
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(width: geometry.size.width, height: geometry.size.height * 9 / 10)
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: isSearching)
        }
    }
}
