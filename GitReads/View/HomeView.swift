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
                FavouritesView()
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search for a repo")
        .navigationViewStyle(.stack)
    }

    func repoSummary(_ repo: GitRepoSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            let fetcher = repoFetcherFor(owner: repo.owner, name: repo.name)
            let screenView = ScreenView(repoFetcher: fetcher)
                .navigationBarTitle("", displayMode: .inline)

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

struct FavouritesView: View {
    @Environment(\.isSearching) var isSearching

    let favourites = ["hashicorp/terraform", "kubernetes/kubernetes"]

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

    var favouritesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(favourites, id: \.self) { favourite in
                    HStack {
                        Spacer()
                        Text(favourite)
                        Spacer()
                    }
                }
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
