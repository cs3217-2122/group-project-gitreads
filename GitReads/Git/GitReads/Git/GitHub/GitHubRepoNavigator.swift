//
//  GitHubRepoNavigator.swift
//  GitReads

import Foundation

struct GitHubRepoNavigator: GitRepoNavigator {

    typealias RepoContentFetcher = (
        _ path: String,
        _ branch: String
    ) async -> Result<GitHubRepoContent, Error>

    private let repoContentFetcher: RepoContentFetcher

    private let cachedDataFetcherFactory: GitHubCachedDataFetcherFactory

    let owner: String
    let repoName: String
    let currentBranch: String

    var rootDir: GitDirectory?

    init(
        owner: String,
        repoName: String,
        branch: String,
        cachedDataFetcherFactory: GitHubCachedDataFetcherFactory,
        repoContentFetcher: @escaping RepoContentFetcher
    ) {
        self.cachedDataFetcherFactory = cachedDataFetcherFactory
        self.repoContentFetcher = repoContentFetcher

        self.owner = owner
        self.repoName = repoName
        self.currentBranch = branch

        let rootDirFetcher = makeDirectoryContentFetcher()
        let rootDirLazyDataSource = LazyDataSource(fetcher: rootDirFetcher)

        self.rootDir = GitDirectory(contents: rootDirLazyDataSource)
        self.rootDir?.contents.preload()
    }

    func contentsAt(path: Path) async -> Result<GitContent, Error> {
        .failure(GitHubRepoContentDecodingError.unexpectedContentType)
//        let repoContent = await fetchRepoContents(at: path.string)
//        repoContent.map { content in
//            switch content {
//            case .directory:
//
//            case .file:
//
//            case .submodule:
//
//            case .symlink:
//
//            }
//        }
    }

    func withBranch(_ newBranch: String) -> GitRepoNavigator {
        GitHubRepoNavigator(
            owner: owner, repoName: repoName,
            branch: newBranch,
            cachedDataFetcherFactory: cachedDataFetcherFactory,
            repoContentFetcher: repoContentFetcher
        )
    }

    private func fetchRepoContents(at path: String) async -> Result<GitHubRepoContent, Error> {
        await repoContentFetcher(path, currentBranch)
    }

    private func makeDirectoryContentFetcher(
        path: String = "",
        sha: String? = nil
    ) -> AnyDataFetcher<[GitContent]> {
        // only cache the repo contents result if the sha is given
        if let sha = sha {
            return cachedDataFetcher(sha: sha) {
                let contents = await self.fetchRepoContents(at: path)
                return contents

            }.flatMap { contents in
                gitHubRepoContentToGitDirectoryContent(contents: contents, atPath: path)
            }
        }

        return AnyDataFetcher {
            let contents = await self.fetchRepoContents(at: path)
            return contents.flatMap { contents in
                gitHubRepoContentToGitDirectoryContent(contents: contents, atPath: path)
            }
        }
    }

    private func gitHubRepoContentToGitDirectoryContent(
        contents: GitHubRepoContent,
        atPath path: String
    ) -> Result<[GitContent], Error> {
        guard case let .directory(directoryContents) = contents else {
            return .failure(GitHubClientError.unexpectedContentType(
                owner: owner,
                repo: repoName,
                path: path
            ))
        }

        let gitContents = directoryContents.map { content in
            GitContent(from: content, contentTypeFunc: {
                self.makeGitContentType(
                    for: $0,
                    at: $0.path
                )
            })
        }

        return .success(gitContents)
    }

    private func makeFileContentFetcher(
        downloadURL: URL?,
        path: String,
        sha: String
    ) -> GitHubCachedDataFetcher<String> {
        cachedDataFetcher(sha: sha) {
            let data = await self.fetchFileData(
                downloadURL: downloadURL,
                path: path
            )

            return data.flatMap {
                let content = String(data: $0, encoding: .utf8)
                guard let content = content else {
                    return .failure(GitHubClientError.cannotBase64Decode(string: "qwe"))
                }

                return .success(content)
            }
        }
    }

    private func fetchFileData(
        downloadURL: URL?,
        path: String
    ) async -> Result<Data, Error> {
        // if the download URL is available we use it directly
        if let downloadURL = downloadURL {
            do {
                let (data, _) = try await URLSession.shared.data(from: downloadURL)
                return .success(data)
            } catch {
                return .failure(GitHubClientError.cannotFetchFileContents(err: error))
            }
        }

        // otherwise we can still obtain the file data by retrieving it from the API
        let contents = await self.fetchRepoContents(at: path)
        return contents.flatMap {
            guard case let .file(fileContent) = $0 else {
                return .failure(
                    GitHubClientError.unexpectedContentType(owner: owner, repo: repoName, path: path)
                )
            }

            assert(fileContent.encoding == .base64, "Unexpected encoding \(fileContent.encoding)")
            let content = fileContent.content

            let data = Data(base64Encoded: content, options: .ignoreUnknownCharacters)
            guard let data = data else {
                return .failure(GitHubClientError.cannotBase64Decode(string: content))
            }

            return .success(data)
        }
    }

    private func makeSubmoduleContentFetcher(
        path: String,
        sha: String
    ) -> GitHubCachedDataFetcher<URL> {
        cachedDataFetcher(sha: sha) {
            let contents = await self.fetchRepoContents(at: path)

            return contents.flatMap {
                guard case let .submodule(submoduleContent) = $0 else {
                    return .failure(
                        GitHubClientError.unexpectedContentType(owner: owner, repo: repoName, path: path)
                    )
                }

                return .success(submoduleContent.submoduleGitURL)
            }
        }
    }

    private func makeSymlinkContentFetcher(
        path: String,
        sha: String
    ) -> GitHubCachedDataFetcher<String> {
        cachedDataFetcher(sha: sha) {
            let contents = await self.fetchRepoContents(at: path)

            return contents.flatMap {
                guard case let .symlink(symlinkContent) = $0 else {
                    return .failure(
                        GitHubClientError.unexpectedContentType(owner: owner, repo: repoName, path: path)
                    )
                }

                return .success(symlinkContent.target)
            }
        }
    }

    private func makeGitContentType(
        for content: GitHubRepoSummaryContent,
        at path: String
    ) -> GitContentType {
        switch content.actualType {
        case .directory:
            let directory = GitDirectory(contents: LazyDataSource(
                fetcher: self.makeDirectoryContentFetcher(
                    path: path,
                    sha: content.sha
                )
            ))
            return .directory(directory)

        case .file:
            let file = GitFile(contents: LazyDataSource(
                fetcher: self.makeFileContentFetcher(
                    downloadURL: content.downloadURL,
                    path: path,
                    sha: content.sha
                )
            ))
            return .file(file)

        case .submodule:
            let submodule = GitSubmodule(gitURL: LazyDataSource(
                fetcher: self.makeSubmoduleContentFetcher(
                    path: path,
                    sha: content.sha
                )
            ))
            return .submodule(submodule)

        case .symlink:
            let symlink = GitSymlink(target: LazyDataSource(
                fetcher: self.makeSymlinkContentFetcher(
                    path: path,
                    sha: content.sha
                )
            ))
            return .symlink(symlink)
        }
    }

    private func cachedDataFetcher<T>(
        sha: String,
        fetcher: @escaping () async -> Result<T, Error>
    ) -> GitHubCachedDataFetcher<T> where T: Codable {
        let key = GitHubCacheKey(owner: owner, repo: repoName, sha: sha)
        return cachedDataFetcherFactory.makeCachedDataFetcher(key: key, fetcher: fetcher)
    }
}
