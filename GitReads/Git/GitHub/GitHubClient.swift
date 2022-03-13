//
//  GitHubClient.swift
//  GitReads

import Foundation

enum GitHubClientError: Error {
    case unexpectedContentType(owner: String, repo: String, path: String)
    case cannotFetchFileContents(err: Error)
    case notUtf8Encoded(data: Data)
    case cannotBase64Decode(string: String)
}

class GitHubClient: GitClient {

    private let api: GitHubApi

    init(gitHubApi: GitHubApi) {
        self.api = gitHubApi
    }

    func getRepository(owner: String, name: String) async -> Result<GitRepo, Error> {
        async let asyncRepo = api.getRepo(owner: owner, name: name)
        async let asyncBranches = api.getRepoBranches(owner: owner, name: name)

        let rootDirFetcher = makeDirectoryContentFetcher(owner: owner, repo: name)
        let rootDirLazyDataSource = LazyDataSource(fetcher: rootDirFetcher)
        rootDirLazyDataSource.preload()

        let (repo, branches) = await (asyncRepo, asyncBranches)
        return repo.flatMap { repo in
            branches.map { branches in
                GitRepo(
                    fullName: repo.fullName,
                    htmlURL: repo.htmlURL,
                    description: repo.description ?? "",
                    defaultBranch: repo.defaultBranch,
                    branches: branches.map { $0.name },
                    rootDir: GitDirectory(contents: rootDirLazyDataSource)
                )
            }
        }
    }

    private func makeDirectoryContentFetcher(
        owner: String,
        repo: String,
        path: String = ""
    ) -> AnyDataFetcher<[GitContent]> {
        AnyDataFetcher {
            let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)

            return contents.flatMap {
                guard case let .directory(directoryContents) = $0 else {
                    return .failure(
                        GitHubClientError.unexpectedContentType(owner: owner, repo: repo, path: path)
                    )
                }

                let gitContents = directoryContents.map { content in
                    GitContent(from: content, contentTypeFunc: { content in
                        self.makeGitContentType(
                            for: content,
                            at: content.path,
                            owner: owner,
                            repo: repo
                        )
                    })
                }

                return .success(gitContents)
            }
        }
    }

    private func makeFileContentFetcher(
        downloadURL: URL?,
        owner: String,
        repo: String,
        path: String
    ) -> AnyDataFetcher<String> {
        AnyDataFetcher {
            let data = await self.fetchFileData(
                downloadURL: downloadURL,
                owner: owner,
                repo: repo,
                path: path
            )

            return data.flatMap {
                let content = String(data: $0, encoding: .utf8)
                guard let content = content else {
                    return .failure(GitHubClientError.notUtf8Encoded(data: $0))
                }

                return .success(content)
            }
        }
    }

    private func fetchFileData(
        downloadURL: URL?,
        owner: String,
        repo: String,
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
        let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)
        return contents.flatMap {
            guard case let .file(fileContent) = $0 else {
                return .failure(
                    GitHubClientError.unexpectedContentType(owner: owner, repo: repo, path: path)
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

    private func makeSubmoduleContentFetcher(owner: String, repo: String, path: String) -> AnyDataFetcher<URL> {
        AnyDataFetcher {
            let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)

            return contents.flatMap {
                guard case let .submodule(submoduleContent) = $0 else {
                    return .failure(
                        GitHubClientError.unexpectedContentType(owner: owner, repo: repo, path: path)
                    )
                }

                return .success(submoduleContent.submoduleGitURL)
            }
        }
    }

    private func makeSymlinkContentFetcher(owner: String, repo: String, path: String) -> AnyDataFetcher<String> {
        AnyDataFetcher {
            let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)

            return contents.flatMap {
                guard case let .symlink(symlinkContent) = $0 else {
                    return .failure(
                        GitHubClientError.unexpectedContentType(owner: owner, repo: repo, path: path)
                    )
                }

                return .success(symlinkContent.target)
            }
        }
    }

    private func makeGitContentType(
        for content: GitHubRepoSummaryContent,
        at path: String,
        owner: String,
        repo: String
    ) -> GitContentType {
        switch content.actualType {
        case .directory:
            let directory = GitDirectory(contents: LazyDataSource(
                fetcher: self.makeDirectoryContentFetcher(owner: owner, repo: repo, path: path)
            ))
            return .directory(directory)

        case .file:
            let file = GitFile(contents: LazyDataSource(
                fetcher: self.makeFileContentFetcher(
                    downloadURL: content.downloadURL,
                    owner: owner,
                    repo: repo,
                    path: path
                )
            ))
            return .file(file)

        case .submodule:
            let submodule = GitSubmodule(gitURL: LazyDataSource(
                fetcher: self.makeSubmoduleContentFetcher(owner: owner, repo: repo, path: path)
            ))
            return .submodule(submodule)

        case .symlink:
            let symlink = GitSymlink(target: LazyDataSource(
                fetcher: self.makeSymlinkContentFetcher(owner: owner, repo: repo, path: path)
            ))
            return .symlink(symlink)
        }
    }
 }
