//
//  GitHubClientTests.swift
//  GitReadsTests

import XCTest
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
                for content in contents {
                    await traverseGitContent(content: content)
                }
            }
        }
    }

    func traverseGitContent(content: GitContent, depth: Int = 0) async {
        if depth > 1 {
            return
        }

        func indentedPrint(_ lala: Any) {
            print(String(repeating: "  ", count: depth) + String(describing: lala))
        }

        indentedPrint("\nname: \(content.name)")
        indentedPrint(content.type)
        switch content.type {
        case let .directory(dir):
            if case let .success(contents) = await dir.contents.value {
                for content in contents {
                    await traverseGitContent(content: content, depth: depth + 1)
                }
            }
        case let .file(file):
            switch await file.contents.value {
            case let .success(contents):
                indentedPrint(contents)
            case let .failure(err):
                indentedPrint("ERROR")
                indentedPrint(err)
            }
        }
    }
}
