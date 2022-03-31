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

    var body: some View {
        VStack(spacing: 20) {
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

            VStack {
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
            Spacer()
        }
        .padding()
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
