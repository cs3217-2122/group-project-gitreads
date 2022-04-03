//
//  GitHubClientTests.swift
//  GitReadsTests

// swiftlint:disable force_try
import XCTest
import Get
import Mocker
@testable import GitReads

extension Encodable {
    func JSONData() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}

struct GitHubClientTestsMockData {
    static let NotFoundErrorResponse = GitHubErrorResponse(
        message: "Not Found",
        errors: nil,
        documentationURL: "https://docs.github.com/rest/reference/repos#get-a-repository"
    )

    static let DefaultBranch = "master"

    static let Repo = GitHubRepo(
        id: 1,
        nodeID: "123",
        name: "something",
        fullName: "someone/something",
        isPrivate: false,
        htmlURL: URL(string: "https://example.com")!,
        description: nil,
        defaultBranch: DefaultBranch,
        owner: "someone"
    )

    static func Branches(names: [String]) -> [GitHubBranch] {
        names.map { GitHubBranch(name: $0) }
    }

    static let TreeSha = "deadbeef"

    static func Ref(refName: String) -> GitHubRef {
        GitHubRef(
            ref: "refs/heads/\(refName)",
            nodeID: "123",
            url: URL(string: "https://example.com")!,
            object: GitHubRef.Object(
                sha: TreeSha,
                type: .commit,
                url: URL(string: "https://example.com")!
            )
        )
    }

    static let Tree = GitHubTree(
        sha: TreeSha,
        url: URL(string: "https://example.com")!,
        objects: [
            GitHubObject(
                path: ".gitignore",
                mode: "100644",
                type: .blob,
                sha: "4296d821",
                size: 100,
                url: nil
            ),
            GitHubObject(
                path: ".README.md",
                mode: "100644",
                type: .blob,
                sha: "1234d329",
                size: 100,
                url: nil
            ),
            GitHubObject(
                path: ".github",
                mode: "040000",
                type: .tree,
                sha: "0ff1c4ab",
                size: nil,
                url: nil
            )
        ],
        truncated: false
    )
}

class GitHubClientTests: XCTestCase {

    var client: GitHubClient!

    override func setUp() {
        super.setUp()
        let httpClient = APIClient(host: GitHubApi.DefaultClientHost) {
            // mock the responses from the API
            $0.sessionConfiguration.protocolClasses = [MockingURLProtocol.self]
            $0.delegate = GitHubErrorHandlingDelegate()
        }

        let api = GitHubApi(client: httpClient)
        client = GitHubClient(gitHubApi: api)
    }

    func testGitHubClient_getRepositoryNotFound() async throws {
        let owner = "someone"
        let repo = "something"
        let url = URL(string: "https://\(GitHubApi.DefaultClientHost)/github/repos/\(owner)/\(repo)")!

        Mock(url: url, dataType: .json, statusCode: 404, data: [
            .get: GitHubClientTestsMockData.NotFoundErrorResponse.JSONData()
        ]).register()

        let res = await client.getRepository(owner: owner, name: repo)
        guard case .failure(let err as GitHubApiError) = res else {
            XCTFail("Expected a GitHubAPIError as response")
            return
        }

        guard case let .badStatusCode(statusCode, message: _) = err else {
            XCTFail("Expected a .badStatusCode error as response")
            return
        }

        XCTAssertEqual(statusCode, 404, "Expected to get a 404 as response")
    }

    // Test whether the client stitches together the data from the API in the correct
    // manner.
    func testGitHubClient_getRepository_refSpecified() async throws {
        let owner = "someone"
        let repo = "something"
        let ref = "sprint-1"
        let branchNames = ["master", "sprint-1", "sprint-2"]

        setupMocks(owner: owner, repo: repo, branchNames: branchNames, ref: ref)

        let result = await client.getRepository(owner: owner, name: repo, ref: .branch(ref))
        guard case let .success(result) = result else {
            XCTFail("Getting repository from client should be successful")
            return
        }

        XCTAssertEqual(result.currBranch, ref,
                       "The returned current branch should be the ref indicated in the request")

        XCTAssertEqual(Set(result.branches), Set(branchNames),
                       "The returned branches should be the same as the branches for the repo")

        XCTAssertEqual(result.tree.commitSha, GitHubClientTestsMockData.TreeSha,
                       "The sha of the returned tree should match the one pointed to by the ref")
    }

    // Test whether the client stitches together the data from the API in the correct
    // manner.
    func testGitHubClient_getRepository_refNotSpecified() async throws {
        let owner = "someone"
        let repo = "something"
        let branchNames = ["master", "sprint-1", "sprint-2"]

        setupMocks(owner: owner, repo: repo, branchNames: branchNames)

        let result = await client.getRepository(owner: owner, name: repo)
        guard case let .success(result) = result else {
            XCTFail("Getting repository from client should be successful")
            return
        }

        XCTAssertEqual(result.currBranch, GitHubClientTestsMockData.DefaultBranch,
                       "The returned current branch should be the ref indicated in the request")

        XCTAssertEqual(Set(result.branches), Set(branchNames),
                       "The returned branches should be the same as the branches for the repo")

        XCTAssertEqual(result.tree.commitSha, GitHubClientTestsMockData.TreeSha,
                       "The sha of the returned tree should match the one pointed to by the ref")
    }

    func setupMocks(
        owner: String,
        repo: String,
        branchNames: [String],
        ref: String = GitHubClientTestsMockData.DefaultBranch
    ) {
        let baseUrl = "https://\(GitHubApi.DefaultClientHost)/github"

        let repoUrl = URL(string: "\(baseUrl)/repos/\(owner)/\(repo)")!
        Mock(url: repoUrl, dataType: .json, statusCode: 200, data: [
            .get: GitHubClientTestsMockData.Repo.JSONData()
        ]).register()

        let repoBranchesUrl = URL(string: "\(baseUrl)/repos/\(owner)/\(repo)/branches")!
        Mock(url: repoBranchesUrl, ignoreQuery: true, dataType: .json, statusCode: 200, data: [
            .get: GitHubClientTestsMockData.Branches(names: branchNames).JSONData()
        ]).register()

        let refUrl = URL(string: "\(baseUrl)/repos/\(owner)/\(repo)/git/ref/heads/\(ref)")!
        Mock(url: refUrl, dataType: .json, statusCode: 200, data: [
            .get: GitHubClientTestsMockData.Ref(refName: ref).JSONData()
        ]).register()

        let treeUrl = URL(
            string: "\(baseUrl)/repos/\(owner)/\(repo)/git/trees/\(GitHubClientTestsMockData.TreeSha)"
        )!
        Mock(url: treeUrl, ignoreQuery: true, dataType: .json, statusCode: 200, data: [
            .get: GitHubClientTestsMockData.Tree.JSONData()
        ]).register()
    }
}
