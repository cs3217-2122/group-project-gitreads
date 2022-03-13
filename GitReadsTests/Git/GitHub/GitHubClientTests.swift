//
//  GitHubClientTests.swift
//  GitReadsTests

import XCTest
import CollectionConcurrencyKit
@testable import GitReads

class GitHubClientTests: XCTestCase {

    func testGitHubClient() async throws {
        let api = GitHubApi()
        let client = GitHubClient(gitHubApi: api)

        let result = await client.getRepository(owner: "weiijiie", name: "nuscats")

        switch result {
        case let .failure(err):
            XCTFail("API request failed with error: \(err)")

        case let .success(res):
            if case let .success(contents) = await res.rootDir.contents.value {
                await contents.concurrentForEach { content in
                    await self.traverseGitContent(content: content)
                }
            }
        }
    }

    func traverseGitContent(content: GitContent, depth: Int = 0) async {
        if depth > 2 {
            return
        }

        func indentedPrint(_ str: Any) {
            print(String(repeating: "    ", count: depth) + String(describing: str))
        }

        print("")
        indentedPrint("name: \(content.name)")
        indentedPrint(content.type)
        switch content.type {
        case let .directory(dir):
            if case let .success(contents) = await dir.contents.value {
                await contents.concurrentForEach { content in
                    await self.traverseGitContent(content: content, depth: depth + 1)
                }
            }
        case let .file(file):
            if case let .failure(err) = await file.contents.value {
                indentedPrint("ERROR")
                indentedPrint(err)
            }

        case let .submodule(submodule):
            if case let .failure(err) = await submodule.gitURL.value {
                indentedPrint("ERROR")
                indentedPrint(err)
            }

        case let .symlink(symlink):
            if case let .failure(err) = await symlink.target.value {
                indentedPrint("ERROR")
                indentedPrint(err)
            }
        }
    }
}
