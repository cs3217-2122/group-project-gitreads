//
//  FavouritesViewModel.swift
//  GitReads

import SwiftUI
import CoreData

class FavouritesViewModel: ObservableObject {

    var updateFavouritesCacheTask: Task<(), Error>?

    let repoService: RepoService

    init(repoService: RepoService) {
        self.repoService = repoService
    }

    deinit {
        updateFavouritesCacheTask?.cancel()
    }

    func onFavouriteReposLoaded<T: Sequence>(
        _ favouritedRepos: T,
        context: NSManagedObjectContext
    ) where T.Element == FavouritedRepo {
        if updateFavouritesCacheTask != nil {
            return
        }

        updateFavouritesCacheTask = Task(priority: .low) {
            for favouritedRepo in favouritedRepos.sorted(using: KeyPathComparator(\.lastUpdated)) {
                if let lastUpdated = favouritedRepo.lastUpdated,
                   lastUpdated.timeIntervalSinceNow.magnitude < 86_400 {
                    continue
                }

                print("\(favouritedRepo.fullName) last saved more than a day ago, saving")

                let repo = try await repoService
                    .getRepository(
                        owner: favouritedRepo.owner ?? "",
                        name: favouritedRepo.name ?? ""
                    )
                    .get()

                // preload the default branch to ensure all the files are cached
                let preloader = repo.accept(visitor: PreloadVisitor(chunkSize: 32))
                preloader.preload()
                _ = await preloader.result
                print("\(favouritedRepo.fullName) saved")

                favouritedRepo.lastUpdated = .now
                try context.save()
            }
        }
    }
}
