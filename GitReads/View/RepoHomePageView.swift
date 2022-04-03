//
//  RepoHomePageView.swift
//  GitReads

import SwiftUI
import CoreData
import MarkdownUI

struct RepoHomePageView: View {

    @State var loading = true
    @State var repo: Repo?

    let handler = makeErrorHandler()

    // Fetches the repo with information for the specified branch. If no branch is specified
    // should use the default branch.
    let repoFetcher: (_ branch: String?) async -> Result<Repo, Error>

    init(repoFetcher: @escaping (String?) async -> Result<Repo, Error>) {
        self.repoFetcher = repoFetcher
    }

    var body: some View {
        ZStack {
            if !loading, let repo = repo {
                RepoLoadedHomePageView(repo: repo, onChangeBranch: { branch in
                    loading = true
                    Task(priority: .userInitiated) { await self.loadRepo(branch: branch) }
                })
            }

            if loading {
                ProgressView()
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .withErrorHandler(handler)
        .onAppear {
            if repo != nil {
                return
            }

            Task(priority: .userInitiated) { await loadRepo(branch: nil) }
        }
    }

    // branch of nil represents the default branch
    private func loadRepo(branch: String? = nil) async {
        let repo = await self.repoFetcher(branch)
        loading = false

        handler.doWithErrorHandling {
            self.repo = try repo.get()
        }
    }
}

struct RepoLoadedHomePageView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appDependencies: AppDependencies

    @FetchRequest var matchingFavouritedRepos: FetchedResults<FavouritedRepo>

    @State private var showCode = false
    @StateObject var viewModel: RepoHomePageViewModel

    let repo: Repo
    let onChangeBranch: (String) -> Void
    let handler = makeErrorHandler()

    init(repo: Repo, onChangeBranch: @escaping (String) -> Void) {
        self._viewModel = StateObject(wrappedValue: RepoHomePageViewModel(repo: repo))
        self.repo = repo
        self.onChangeBranch = onChangeBranch

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
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    repoInfoHeader
                    favouriteRepoButton
                    changeBranchSection
                    Divider()
                    if let readmeContents = viewModel.readmeContents {
                        Markdown(
                            readmeContents,
                            baseURL: URL(
                                string: "https://github.com/\(repo.owner)/\(repo.name)/raw/\(repo.currBranch)/"
                            )
                        )
                    }
                    Spacer()
                }
                .padding()
            }
            showCodeSection

            let screenView = ScreenView(repo: repo)
                .navigationBarTitle("\(repo.owner)/\(repo.name)", displayMode: .inline)

            NavigationLink("", destination: screenView, isActive: $showCode)
                .hidden()
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .withErrorHandler(handler)
        .onAppear {
            viewModel.setRepoService(repoService: appDependencies.repoService)
            Task {
                await handler.doAsyncWithErrorHandling {
                    try await viewModel.loadReadme()
                }
            }
        }
        .onDisappear {
            viewModel.cleanUp()
        }
    }

    var repoInfoHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(repo.owner)
                    .font(.title3)
                    .foregroundColor(.gray)
                HStack {
                    Text(repo.name)
                        .font(.title)
                        .fontWeight(.semibold)
                    if let htmlURL = repo.htmlURL {
                        Link(destination: htmlURL) {
                            Image(systemName: "link").font(.footnote)
                        }
                    }
                }
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
                handler.doWithErrorHandling {
                    try viewModel.unfavouriteRepository(
                        context: managedObjectContext,
                        repos: matchingFavouritedRepos
                    )
                }
            } else {
                handler.doWithErrorHandling {
                    try viewModel.favouriteRepository(context: managedObjectContext)
                }
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

    var changeBranchSection: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            Text("On: ")
                .fontWeight(.light)
                .opacity(0.9)
            Text(repo.currBranch)
                .fontWeight(.bold)
                .lineLimit(1)
            Spacer()
            NavigationLink(destination: selectBranchView) {
                Text("Change Branch")
            }
            Spacer()
        }
        .padding(.top)
    }

    var showCodeButton: some View {
        Button {
            showCode = true
        } label: {
            Label {
                Text("View Code")
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
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.green)
                        .opacity(0.5)
                }
        }
    }

    var showCodeSection: some View {
        VStack {
            showCodeButton
        }
        .padding(.horizontal)
        .padding(.top, 28)
        .padding(.bottom, 44) // considering using geometry reader to get safe insets
        .background {
            Rectangle()
                .fill(Color(.systemGray6))
                .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .frame(alignment: .bottom)
    }

    var selectBranchView: SelectBranchView {
        SelectBranchView(
            defaultBranch: repo.defaultBranch,
            branches: repo.branches,
            onBranchSelected: onChangeBranch
        )
    }
}
