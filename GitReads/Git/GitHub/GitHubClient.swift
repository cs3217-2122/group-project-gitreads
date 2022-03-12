//
//  GitHubClient.swift
//  GitReads

enum GitHubClientError: Error {
    case unexpectedContentType(owner: String, repo: String, path: String)
}

class GitHubClient: GitClient {

    private let api: GitHubApi

    init(gitHubApi: GitHubApi) {
        self.api = gitHubApi
    }

    func getRepository(owner: String, name: String) async -> Result<GitRepo, Error> {
        let repo = await api.getRepo(owner: owner, name: name)
        let branches = await api.getRepoBranches(owner: owner, name: name)

        let rootDirFetcher = makeDirectoryContentFetcher(owner: owner, repo: name)
        let rootDirLazyDataSource = LazyDataSource(fetcher: rootDirFetcher)
        rootDirLazyDataSource.preload()

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

    private func makeFileContentFetcher(owner: String, repo: String, path: String) -> AnyDataFetcher<String> {
        AnyDataFetcher {
            let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)

            return contents.flatMap {
                guard case let .file(fileContent) = $0 else {
                    return .failure(GitHubClientError.unexpectedContentType(
                        owner: owner,
                        repo: repo,
                        path: path
                    ))
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

    private func makeDirectoryContentFetcher(
        owner: String,
        repo: String,
        path: String = ""
    ) -> AnyDataFetcher<[GitContent]> {
        AnyDataFetcher {
            let contents = await self.api.getRepoContents(owner: owner, name: repo, path: path)

            return contents.flatMap {
                guard case let .directory(directoryContents) = $0 else {
                    return .failure(GitHubClientError.unexpectedContentType(
                        owner: owner,
                        repo: repo,
                        path: path
                    ))
                }

                let gitContents: [GitContent] = directoryContents.map { content in
                    self.gitHubRepoContentToGitContent(content, owner: owner, repo: repo)
                }

                return .success(gitContents)
            }
        }
    }

    private func gitHubRepoContentToGitContent(
        _ content: GitHubRepoSummaryContent,
        owner: String,
        repo name: String
    ) -> GitContent {
        switch content.type {
        case .file:
            let file = GitFile(contents: LazyDataSource(
                fetcher: self.makeFileContentFetcher(
                    owner: owner,
                    repo: name,
                    path: content.path
                )
            ))

            return GitContent(
                type: .file(file),
                name: content.name,
                path: content.path,
                sha: content.sha,
                htmlURL: content.htmlURL,
                sizeInBytes: content.size
            )

        case .directory:
            let directory = GitDirectory(contents: LazyDataSource(
                fetcher: self.makeDirectoryContentFetcher(
                    owner: owner,
                    repo: name,
                    path: content.path
                )
            ))

            return GitContent(
                type: .directory(directory),
                name: content.name,
                path: content.path,
                sha: content.sha,
                htmlURL: content.htmlURL,
                sizeInBytes: content.size
            )
        }
    }
 }
