//
//  GitHubClient.swift
//  GitReads

import Foundation

enum GitHubClientError: Error {
    case unexpectedContentType(owner: String, repo: String, path: String)
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
                    GitContent(from: content, contentTypeFunc: { type in
                        self.makeGitContentType(for: type, at: content.path, owner: owner, repo: repo)
                    })
                }

                return .success(gitContents)
            }
        }
    }

    private func makeFileContentFetcher(owner: String, repo: String, path: String) -> AnyDataFetcher<String> {
        AnyDataFetcher {
            let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)

            return contents.flatMap {
                guard case let .file(fileContent) = $0 else {
                    return .failure(
                        GitHubClientError.unexpectedContentType(owner: owner, repo: repo, path: path)
                    )
                }

                assert(fileContent.encoding == .base64, "Unexpected encoding \(fileContent.encoding)")
                // There should only be base64 encoded contents, but we fail gracefully
                // by providing the encoded content if it is not base64 encoded.
                guard case .base64 = fileContent.encoding else {
                    return .success(fileContent.content)
                }

                return .success(fileContent.content.base64Decoded() ?? "")
            }
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
        for contentType: GitHubRepoSummaryContent.ContentType,
        at path: String,
        owner: String,
        repo: String
    ) -> GitContentType {
        switch contentType {
        case .directory:
            let directory = GitDirectory(contents: LazyDataSource(
                fetcher: self.makeDirectoryContentFetcher(owner: owner, repo: repo, path: path)
            ))
            return .directory(directory)

        case .file:
            let file = GitFile(contents: LazyDataSource(
                fetcher: self.makeFileContentFetcher(owner: owner, repo: repo, path: path)
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
