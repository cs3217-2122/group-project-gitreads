//
//  GitHubApi.swift
//  GitReads

import Get
import Foundation
import class Cache.Storage
import class Cache.TransformerFactory
import struct Cache.DiskConfig
import struct Cache.MemoryConfig
import Reachability

enum GitHubApiError: Error {
    case rateLimited
    case contentTooLarge(message: String = "")
    case badStatusCode(Int, message: String = "")
    case malformedPath(path: String)
    case couldNotDecode(encoding: String.Encoding, data: Data)
}

class GitHubApi {

    // We use a proxy to handle basic authentication to the GitHub API on the server side
    static let DefaultClientHost = "gitreads-proxy.fly.dev"

    static let DefaultClient = APIClient(host: DefaultClientHost) {
        $0.sessionConfiguration.httpAdditionalHeaders = ["Accept": "application/vnd.github.v3+json"]
        $0.delegate = GitHubErrorHandlingDelegate()
    }

    static let DefaultCacheDiskConfig = DiskConfig(
        name: "github-cache",
        expiry: .date(Date().addingTimeInterval(30 * 86_400)), // 30 days
        maxSize: 64_000_000 // 64MB
    )

    static let DefaultCacheMemoryConfig = MemoryConfig(
        expiry: .date(Date().addingTimeInterval(30 * 60)), // 30 minutes
        countLimit: 30
    )

    static let DefaultStorage: Storage<String, String>? = try? Storage(
        diskConfig: GitHubApi.DefaultCacheDiskConfig,
        memoryConfig: GitHubApi.DefaultCacheMemoryConfig,
        transformer: TransformerFactory.forCodable(ofType: String.self)
    )

    private let storage: Storage<String, String>?
    private let client: APIClient

    private var reachability = try? Reachability()
    private var offline = false

    init(client: APIClient = GitHubApi.DefaultClient, storage: Storage<String, String>? = DefaultStorage) {
        self.client = client
        self.storage = storage

        guard let reachability = reachability else {
            return
        }

        reachability.whenReachable = { _ in
            self.offline = false
        }

        reachability.whenUnreachable = { _ in
            self.offline = true
            print("offline")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start network reachability notifier")
        }

        self.offline = reachability.connection == .unavailable
    }

    deinit {
        if let reachability = reachability {
            reachability.stopNotifier()
        }
    }

    func searchRepos(query: String) async -> Result<PaginatedResponse<GitHubRepo>, Error> {
        await doAsyncWithResult {
            let req: Request<GitHubSearchResponse> = .get(
                path("search", "repositories"),
                query: [("q", query), ("per_page", "20")]
            )

            let result = try await client.send(req)
            let linkHeader = (result.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Link") ?? ""
            let pageInfo = GitHubPageInfo(linkHeader: linkHeader)

            return PaginatedResponse(
                items: result.value.items,
                pageFetcher: { url in
                    await self.searchRepos(fromUrl: url)
                        .map { repos, info in
                            PaginatedValue(items: repos, prevUrl: info.prevUrl, nextUrl: info.nextUrl)
                        }
                },
                prevUrl: pageInfo.prevUrl,
                nextUrl: pageInfo.nextUrl
            )
        }
    }

    private func searchRepos(
        fromUrl url: URL
    ) async -> Result<(repos: [GitHubRepo], info: GitHubPageInfo), Error> {
        await doAsyncWithResult {
            let req: Request<GitHubSearchResponse> = .get(url.absoluteString)

            let result = try await client.send(req)
            let linkHeader = (result.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Link") ?? ""
            let pageInfo = GitHubPageInfo(linkHeader: linkHeader)

            return (repos: result.value.items, info: pageInfo)
        }
    }

    /// Fetches the repository with the given `owner` and repo `name` from the GitHub API.
    func getRepo(owner: String, name repo: String) async -> Result<GitHubRepo, Error> {
        let reqPath = path("repos", owner, repo)
        return await cache(key: reqPath) {
            let req: Request<GitHubRepo> = .get(reqPath)

            let result = try await client.send(req)
            return result.value
        }
    }

    /// Fetches the contents of the repository with the given `owner` and repo `name` at the given `path` from
    /// the GitHub API. The root of the repository is denoted with an empty path. `ref` can be specified to get the
    /// contents from a specific commit/branch/tag.If no `ref` is specified, defaults to the default branch of the
    /// repo.
    func getRepoContents(
        owner: String,
        name repo: String,
        path contentPath: String = "",
        ref: String? = nil
    ) async -> Result<GitHubRepoContent, Error> {
        await doAsyncWithResult {
            let req: Request<GitHubRepoContent> = .get(
                path("repos", owner, repo, "contents", contentPath),
                query: [("ref", ref)]
            )

            let result = try await client.send(req)
            return result.value
        }
    }

    /// Fetches the first 100 branches of the repository with the given `owner` and repo `name`.
    func getRepoBranches(owner: String, name repo: String) async -> Result<[GitHubBranch], Error> {
        let reqPath = path("repos", owner, repo, "branches")

        return await cache(key: reqPath) {
            let req: Request<[GitHubBranch]> = .get(
                reqPath,
                query: [("per_page", "100")]
            )

            let result = try await client.send(req)
            return result.value
        }
    }

    func getRef(owner: String, repoName: String, ref: GitRef) async -> Result<GitHubRef, Error> {
        let reqPath = path("repos", owner, repoName, "git", "ref", pathString(for: ref))

        return await cache(key: reqPath) {
            let req: Request<GitHubRef> = .get(reqPath)

            let result = try await client.send(req)
            return result.value
        }
    }

    func getTree(
        owner: String,
        repoName: String,
        treeSha: String,
        recursive: Bool = true
    ) async -> Result<GitHubTree, Error> {
        let reqPath = path("repos", owner, repoName, "git", "trees", treeSha)

        return await cache(key: reqPath) {
            var req: Request<GitHubTree> = .get(reqPath)
            if recursive {
                req.query = [("recursive", "true")]
            }

            let result = try await client.send(req)
            return result.value
        }
    }

    func getRawGitHubUserContent(
        owner: String,
        repo: String,
        commitSha: String,
        path contentPath: Path
    ) async -> Result<Data, Error> {
        let fullPath = path(
            owner, repo, commitSha, contentPath.string,
            prefix: "https://raw.githubusercontent.com/"
        )

        do {
            let url = try URL(string: fullPath)
                .unwrapOrThrow(error: GitHubApiError.malformedPath(path: fullPath))

            let (data, _) = try await URLSession.shared.data(from: url)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }

    func getRawGitHubUserContent(
        owner: String,
        repo: String,
        commitSha: String,
        path contentPath: Path,
        encoding: String.Encoding
    ) async -> Result<String, Error> {
        let data = await getRawGitHubUserContent(
            owner: owner,
            repo: repo,
            commitSha: commitSha,
            path: contentPath
        )

        return data.flatMap { data in
            Result {
                try String(data: data, encoding: encoding)
                    .unwrapOrThrow(error: GitHubApiError.couldNotDecode(encoding: encoding, data: data))
            }
        }
    }

    private func pathString(for ref: GitRef) -> String {
        switch ref {
        case let .branch(name):
            return "heads/\(name)"
        case let .tag(name):
            return "tags/\(name)"
        }
    }

    private func path(_ pathComponents: String..., prefix: String = "/github/") -> String {
        prefix + pathComponents.joined(separator: "/")
    }

    private func cache<T: Codable>(
        key: String,
        _ fetcher: () async throws -> T
    ) async -> Result<T, Error> {
        // only if offline, do we try using the cache first
        if offline, let storage = storage {
            let typedStorage = storage.transformCodable(ofType: T.self)

            let result = Result { try typedStorage.object(forKey: key) }
            if case .success = result {
                return result
            }
        }

        let result = await doAsyncWithResult {
            try await fetcher()
        }

        // cache the value if returned succcesfully
        if case let .success(value) = result, let storage = storage {
            let typedStorage = storage.transformCodable(ofType: T.self)
            do {
                try typedStorage.setObject(value, forKey: key)
            } catch {
                print("Error caching value: \(error)")
            }
        }

        return result
    }

    /// Performs the given throwable action. If successful, returns `.success` with the returned value from the action.
    /// If an error is thrown, wraps that error in `.failure` and returns it.
    private func doAsyncWithResult<T>(_ action: () async throws -> T) async -> Result<T, Error> {
        do {
            let res = try await action()
            return .success(res)
        } catch {
            return .failure(error)
        }
    }
}

class GitHubErrorHandlingDelegate: APIClientDelegate {
    func client(_ client: APIClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error {
        let rateLimitRemaining = response
            .value(forHTTPHeaderField: "x-ratelimit-remaining")
            .flatMap { Int($0) }

        if let rateLimitRemaining = rateLimitRemaining,
           rateLimitRemaining <= 0 && response.statusCode == 403 {
            return GitHubApiError.rateLimited
        }

        do {
            let decoder = JSONDecoder()
            let error = try decoder.decode(GitHubErrorResponse.self, from: data)

            if let errors = error.errors, errors.contains(where: { $0.code == .tooLarge }) {
                return GitHubApiError.contentTooLarge(message: error.message)
            }

            return GitHubApiError.badStatusCode(response.statusCode, message: error.message)

        } catch {
            print(error)
            return GitHubApiError.badStatusCode(
                response.statusCode,
                message: String(decoding: data, as: UTF8.self)
            )
        }
    }
}
