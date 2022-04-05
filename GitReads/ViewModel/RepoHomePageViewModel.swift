//
//  RepoHomePageViewModel.swift
//  GitReads

import SwiftUI
import CoreData

class RepoHomePageViewModel: ObservableObject {

    @Published var readmeContents: String?

    let repo: Repo
    private var preloader: Preloader
    var repoService: RepoService?

    init(repo: Repo) {
        self.repo = repo
        self.preloader = repo.accept(visitor: PreloadVisitor())
        preloader.preload()
    }

    deinit {
        cleanUp()
    }

    func setRepoService(repoService: RepoService) {
        self.repoService = repoService
    }

    func cleanUp() {
        self.preloader.cancel()
    }

    @MainActor func loadReadme() async throws {
        if readmeContents != nil {
            return
        }

        let readme = repo.root.files.first { $0.isReadme() }
        guard let readme = readme else {
            readmeContents = "*No description provided*"
            return
        }

        let readmeLines = try await readme.parseOutput.value.get().lines
        readmeContents = readmeLines.map { $0.content }.joined(separator: "\n")
    }

    func favouriteRepository(context: NSManagedObjectContext) throws {
        let favouritedRepo = FavouritedRepo(context: context)
        favouritedRepo.name = repo.name
        favouritedRepo.owner = repo.owner
        favouritedRepo.platform = repo.platform
        favouritedRepo.lastUpdated = .now

        try context.save()

        guard let repoService = repoService else {
            return
        }

        Task(priority: .low) {
            let repo = try await repoService.getRepository(owner: repo.owner, name: repo.name).get()

            // preload the default branch to ensure all the files are cached
            let preloader = repo.accept(visitor: PreloadVisitor(chunkSize: 32))
            preloader.preload()
            _ = await preloader.result
            print("Saved \(repo.fullName) for offline use")
        }
    }

    func unfavouriteRepository<T: Sequence>(
        context: NSManagedObjectContext,
        repos: T
    ) throws where T.Element == FavouritedRepo {
        for repo in repos {
            context.delete(repo)
        }
        try context.save()
    }
}
