//
//  RepoHomePageViewModel.swift
//  GitReads

import SwiftUI
import CoreData

class RepoHomePageViewModel: ObservableObject {

    @Published var readmeContents: String?

    let repo: Repo
    private var preloader: PreloadVisitor?

    init(repo: Repo) {
        self.repo = repo
        self.preload()
        self.loadReadme()
    }

    func cleanUp() {
        self.preloader?.stop()
    }

    func preload() {
        self.preloader = PreloadVisitor()
        if let preloader = preloader {
            self.repo.accept(visitor: preloader)
            preloader.preload()
        }
    }

    func loadReadme() {
        let readme = repo.root.files.first { $0.isReadme() }
        guard let readme = readme else {
            readmeContents = "*No description provided*"
            return
        }

        Task { @MainActor in
            let readmeLines = await readme.lines.value
            switch readmeLines {
            case let .success(lines):
                readmeContents = lines.map { $0.content }.joined(separator: "\n")
            case let .failure(err):
                print("Error: \(err.localizedDescription)")
            }
        }
    }

    func favouriteRepository(context: NSManagedObjectContext) throws {
        let favouritedRepo = FavouritedRepo(context: context)
        favouritedRepo.name = repo.name
        favouritedRepo.owner = repo.owner
        favouritedRepo.platform = repo.platform

        try context.save()
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
