//
//  FavouritesViewModel.swift
//  GitReads

import SwiftUI

class FavouritesViewModel: ObservableObject {
    func onFavouriteReposLoaded<T: Sequence>(_ repos: T) where T.Element == FavouritedRepo {
        for repo in repos.sorted(using: KeyPathComparator(\.lastUpdated)) {
            if let lastUpdated = repo.lastUpdated,
               lastUpdated.timeIntervalSinceNow.magnitude < 86_400 {
                continue
            }

            print("\(repo.fullName) last saved more than a day ago, saving")

        }
    }
}
