//
//  GitHubApi.swift
//  GitReads

import Get
import Foundation

enum GitHubApiError: Error {
    case rateLimited
    case contentTooLarge(message: String = "")
    case badStatusCode(Int, message: String = "")
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

class GitHubApi {

    private let client: APIClient

    static let DefaultClient = APIClient(host: "api.github.com") {
        $0.sessionConfiguration.httpAdditionalHeaders = ["Accept": "application/vnd.github.v3+json"]
        $0.delegate = GitHubErrorHandlingDelegate()
    }

    init(client: APIClient = GitHubApi.DefaultClient) {
        self.client = client
    }

    /// Fetches the repository with the given `owner` and repo `name` from the GitHub API.
    func getRepo(owner: String, name repo: String) async -> Result<GitHubRepo, Error> {
        await doAsyncWithResult {
            let req: Request<GitHubRepo> = .get(path("repos", owner, repo))

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
        await doAsyncWithResult {
            let req: Request<[GitHubBranch]> = .get(
                path("repos", owner, repo, "branches"),
                query: [("per_page", "100")]
            )

            let result = try await client.send(req)
            return result.value
        }
    }

    private func path(_ pathComponents: String...) -> String {
        "/" + pathComponents.joined(separator: "/")
    }

    /// Performs the given throwable action. If successful, returns `.success` with the returned value from the action.
    /// If an error is thrown, wraps that error in `.failure` and returns it.
    private func doAsyncWithResult<T>(action: () async throws -> T) async -> Result<T, Error> {
        do {
            let res = try await action()
            return .success(res)
        } catch {
            return .failure(error)
        }
    }
}
