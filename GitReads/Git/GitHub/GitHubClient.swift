//
//  GitHubClient.swift
//  GitReads

import Cache
import Foundation

enum GitHubClientError: Error {
    case unexpectedContentType(owner: String, repo: String, path: String)
}

class GitHubClient: GitClient {

    private let api: GitHubApi
    private let cachedDataFetcherFactory: GitHubCachedDataFetcherFactory?

    /// Initializes the `GitHubClient` with the given `GitHubApi` and
    /// `GitHubCachedDataFetcherFactory`. If the factory is nil, the client will still
    /// be initialized, but the any fetched will not be cached.
    init(gitHubApi: GitHubApi, cachedDataFetcherFactory: GitHubCachedDataFetcherFactory?) {
        self.api = gitHubApi
        self.cachedDataFetcherFactory = cachedDataFetcherFactory
    }

    func searchRepositories(query: String) async -> Swift.Result<PaginatedResponse<GitRepoSummary>, Error> {
        let repos = await api.searchRepos(query: query)
        return repos.map {
            $0.map { item in
                GitRepoSummary(
                    owner: item.owner,
                    name: item.name,
                    fullName: item.fullName,
                    htmlURL: item.htmlURL,
                    description: item.description ?? "",
                    defaultBranch: item.defaultBranch
                )
            }
        }
    }

    func getRepository(
        owner: String,
        name: String,
        ref: GitRef? = nil
    ) async -> Swift.Result<GitRepo, Error> {

        async let asyncBranches = api.getRepoBranches(owner: owner, name: name)
        let repo = await api.getRepo(owner: owner, name: name)

        let tree = await repo.asyncFlatMap { repo in
            await api.getRef(owner: owner, repoName: name, ref: ref ?? .branch(repo.defaultBranch))
        }
        .asyncFlatMap { ref in
            await self.api.getTree(owner: owner, repoName: name, treeSha: ref.object.sha)
        }

        let branches = await asyncBranches

        return repo.flatMap { repo in
            branches.flatMap { branches in
                tree.map { tree in
                    makeGitRepo(repo: repo, branches: branches, tree: tree, ref: ref)
                }
            }
        }
    }

    private func makeGitRepo(
        repo: GitHubRepo,
        branches: [GitHubBranch],
        tree: GitHubTree,
        ref: GitRef?
    ) -> GitRepo {
        let currBranch = ref?.name ?? repo.defaultBranch
        let tree = GitTree(
            commitSha: tree.sha,
            gitObjects: tree.objects.map(GitObject.init),
            fileContentFetcher: { object, commitSha in
                self.getFileContent(
                    owner: repo.owner,
                    repoName: repo.name,
                    object: object,
                    commitSha: commitSha
                )
            },
            symlinkContentFetcher: { object, commitSha in
                self.getSymlinkContent(
                    owner: repo.owner,
                    repoName: repo.name,
                    object: object,
                    commitSha: commitSha
                )
            },
            submoduleContentFetcher: { object, commitSha in
                self.getSubmoduleContent(
                    owner: repo.owner,
                    repoName: repo.name,
                    object: object,
                    commitSha: commitSha
                )
            }
        )

        return GitRepo(
            name: repo.name,
            owner: repo.owner,
            htmlURL: repo.htmlURL,
            description: repo.description ?? "",
            platform: .github,
            defaultBranch: repo.defaultBranch,
            branches: branches.map { $0.name },
            currBranch: currBranch,
            tree: tree
        )
    }

    private func getFileContent(
        owner: String,
        repoName: String,
        object: GitObject,
        commitSha: String
    ) -> GitContent {
        let fetcher = rawGitHubUserContentFetcher(
            owner: owner, repoName: repoName, object: object, commitSha: commitSha
        )

        let file = GitFile(contents: LazyDataSource(fetcher: fetcher))
        return GitContent(from: object, type: .file(file))
    }

    private func getSymlinkContent(
        owner: String,
        repoName: String,
        object: GitObject,
        commitSha: String
    ) -> GitContent {
        let fetcher = rawGitHubUserContentFetcher(
            owner: owner, repoName: repoName, object: object, commitSha: commitSha
        )

        let symlink = GitSymlink(target: LazyDataSource(fetcher: fetcher))
        return GitContent(from: object, type: .symlink(symlink))
    }

    private func getSubmoduleContent(
        owner: String,
        repoName: String,
        object: GitObject,
        commitSha: String
    ) -> GitContent {
        let fetcher = submoduleContentFetcher(
            owner: owner, repoName: repoName, object: object, commitSha: commitSha
        )

        let submodule = GitSubmodule(gitURL: LazyDataSource(fetcher: fetcher))
        return GitContent(from: object, type: .submodule(submodule))
    }

    private func rawGitHubUserContentFetcher(
        owner: String,
        repoName: String,
        object: GitObject,
        commitSha: String
    ) -> AnyDataFetcher<String> {
        dataFetcherFor(owner: owner, repo: repoName, sha: object.sha) {
            await self.api.getRawGitHubUserContent(
                owner: owner,
                repo: repoName,
                commitSha: commitSha,
                path: object.path,
                encoding: .utf8
            )
        }
    }

    private func submoduleContentFetcher(
        owner: String,
        repoName: String,
        object: GitObject,
        commitSha: String
    ) -> AnyDataFetcher<URL> {
        dataFetcherFor(owner: owner, repo: repoName, sha: object.sha) {
            let contents = await self.api.getRepoContents(
                owner: owner, name: repoName, path: object.path.string, ref: commitSha
            )

            return contents.flatMap { contents in
                guard case let .submodule(submoduleContent) = contents else {
                    return .failure(GitHubClientError.unexpectedContentType(
                        owner: owner, repo: repoName, path: object.path.string
                    ))
                }

                return .success(submoduleContent.submoduleGitURL)
            }
        }
    }

    /// Returns a cached data fetcher if the cache data fetcher is defined, otherwise returns an ordinary data fetcher.
    private func dataFetcherFor<T: Codable>(
        owner: String,
        repo: String,
        sha: String,
        fetcher: @escaping () async -> Swift.Result<T, Error>
    ) -> AnyDataFetcher<T> {
        guard let cachedDataFetcherFactory = cachedDataFetcherFactory else {
            return AnyDataFetcher(fetcher: fetcher)
        }

        let key = GitHubCacheKey(owner: owner, repo: repo, sha: sha)
        return AnyDataFetcher(
            cachedDataFetcherFactory.makeCachedDataFetcher(key: key, fetcher: fetcher)
        )
    }
 }
