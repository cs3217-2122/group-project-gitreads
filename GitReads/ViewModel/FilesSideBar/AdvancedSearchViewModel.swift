//
//  AdvancedSearchViewModel.swift
//  GitReads

import Foundation
import Combine

class AdvancedSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var options: [FileNavigateOption] = []

    private let repo: Repo
    private var subscriptions: Set<AnyCancellable> = []
    private var previousSubscription: AnyCancellable?

    init(repo: Repo, onSelect: @escaping (FileNavigateOption) -> Void = { _ in }) {
        self.repo = repo
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { value in
                if value.isEmpty {
                    self.options = []
                } else {
                    self.previousSubscription?.cancel()
                    self.previousSubscription = self.repo.accept(visitor: TextSearchVisitor(textSearch: value))
                        .receive(on: DispatchQueue.main)
                        .sink { navOptions in
                            self.options = navOptions
                        }

                }
            }
            .store(in: &subscriptions)
    }
}
