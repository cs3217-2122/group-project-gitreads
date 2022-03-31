//
//  RepoHomePageView.swift
//  GitReads

import SwiftUI
import CoreData

struct RepoHomePageView: View {

    @State var loading = true
    @State var repo: Repo?

    let repoFetcher: () async -> Result<Repo, Error>

    init(repoFetcher: @escaping () async -> Result<Repo, Error>) {
        self.repoFetcher = repoFetcher
    }

    var body: some View {
        ZStack {
            if let repo = repo {
                RepoLoadedHomePageView(repo: repo)
            }

            if loading {
                ProgressView()
            }
        }
        .onAppear {
            Task(priority: .userInitiated) {
                let repo = await self.repoFetcher()
                loading = false
                // TODO: handle errors
                if case let .success(repo) = repo {
                    self.repo = repo
                    // TODO: do the preloading
//                    initializeWithRepo(repo)
                }
            }
        }
        .onDisappear {
//            viewModel.cleanUp()
        }
    }
}

struct RepoLoadedHomePageView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest var matchingFavouritedRepos: FetchedResults<FavouritedRepo>

    @State var repo: Repo
    @State private var showCode = false

    init(repo: Repo) {
        self._repo = State(wrappedValue: repo)

        let predicate = NSPredicate(
            format: "name == %@ && owner == %@ && platformValue == %@",
            repo.name, repo.owner, repo.platform.rawValue
        )

        _matchingFavouritedRepos = FetchRequest<FavouritedRepo>(
            sortDescriptors: [],
            predicate: predicate
        )
    }

    var favourited: Bool {
        matchingFavouritedRepos.contains { elem in
            repo.name == elem.name
            && repo.owner == elem.owner
            && repo.platform == elem.platform
        }
    }

    var repoInfoHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(repo.owner)
                    .font(.title3)
                    .foregroundColor(.gray)
                Text(repo.name)
                    .font(.title)
                    .fontWeight(.semibold)
                Text(repo.description)
                    .font(.body)
                    .fontWeight(.light)
                    .lineLimit(4)
            }
            Spacer()
        }
    }

    var favouriteRepoButton: some View {
        Button {
            if favourited {
                self.unfavouriteRepository()
            } else {
                self.favouriteRepository()
            }
        } label: {
            Label {
                Text(favourited ? "Favourited" : "Favourite")
            } icon: {
                Image(systemName: favourited ? "heart.fill" : "heart")
                    .foregroundColor(favourited ? .pink : .gray)
            }
            .frame(
              minWidth: 0,
              maxWidth: .infinity
            )
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color(.darkGray))
                .background(Rectangle().fill(Color(.systemGray6)))
        }
    }

    var showCodeButton: some View {
        Button {
            showCode = true
        } label: {
            Label {
                Text("View the code!")
                    .font(.title3)
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundColor(.green)
                    .brightness(-0.5)
            }
            .frame(
              minWidth: 0,
              maxWidth: .infinity
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color(.darkGray))
                .background {
                    Rectangle()
                        .fill(.green)
                        .opacity(0.6)
                }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    repoInfoHeader
                    VStack {
                        favouriteRepoButton
                    }
                    Spacer()
                }
                .padding()
            }
            let screenView = ScreenView(repo: repo)
                .navigationBarTitle("\(repo.owner)/\(repo.name)", displayMode: .inline)
            NavigationLink("", destination: screenView, isActive: $showCode)
                .hidden()
            VStack {
                showCodeButton
            }
            .padding(.horizontal)
            .padding(.top, 28)
            .padding(.bottom, 44) // considering using geometry reader to get safe insets
            .background {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .cornerRadius(24, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(alignment: .bottom)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private func favouriteRepository() {
        let favouritedRepo = FavouritedRepo(context: managedObjectContext)
        favouritedRepo.name = repo.name
        favouritedRepo.owner = repo.owner
        favouritedRepo.platform = repo.platform

        saveContext()
    }

    private func unfavouriteRepository() {
        for match in matchingFavouritedRepos {
            managedObjectContext.delete(match)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            // TODO: handle errors
            print(error)
        }
    }
}
