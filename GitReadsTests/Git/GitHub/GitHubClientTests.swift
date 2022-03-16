//
//  GitHubClientTests.swift
//  GitReadsTests

import XCTest
import CollectionConcurrencyKit
import Cache
@testable import GitReads

extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        if range.endIndex > endIndex {
            if range.startIndex >= endIndex {
                return []
            } else {
                return self[range.startIndex..<endIndex]
            }
        } else {
            return self[range]
        }
    }
}

class GitHubClientTests: XCTestCase {

    func testSomething() async throws {
        let api = GitHubApi()

        let ref = await api.getRef(owner: "weiijiie", repoName: "nuscats", ref: .branch("main"))
        let tree = await ref.asyncFlatMap { ref in
            await api.getTree(owner: "weiijiie", repoName: "nuscats", treeSha: ref.object.sha)
        }

        guard case let .success(tree) = tree else {
            XCTFail("fail lol")
            return
        }

        let file = GitFile(contents: LazyDataSource(fetcher: AnyDataFetcher {
            .success("file!")
        }))

        let symlink = GitSymlink(target: LazyDataSource(fetcher: AnyDataFetcher {
            .success("./symlink!")
        }))

        let submodule = GitSubmodule(gitURL: LazyDataSource(fetcher: AnyDataFetcher {
            .success(URL(fileURLWithPath: "/submodule"))
        }))

        let gitTree = GitTree(
            commitSha: tree.sha,
            gitObjects: tree.objects.map { object in
                GitObject(from: object)
            },
            fileContentFetcher: { object, _ in GitContent(from: object, type: .file(file)) },
            symlinkContentFetcher: { object, _ in GitContent(from: object, type: .symlink(symlink)) },
            submoduleContentFetcher: { object, _ in GitContent(from: object, type: .submodule(submodule)) }
        )

        let rootDir = gitTree.rootDir
        let rootDirContents = try await rootDir.contents.value.get()
        for content in rootDirContents {
            await printContentType(content.type)
        }

        let content = gitTree.content(at: Path(components: ".dockerignore"))
        guard let content = content else {
            XCTFail("content nil")
            return
        }

        await printContentType(content.type)
    }

    func printContentType(_ contentType: GitContentType) async {
        switch contentType {
        case let .directory(dir):
            print(await dir.contents.value)
        case let .file(file):
            print(await file.contents.value)
        case let .submodule(submodule):
            print(await submodule.gitURL.value)
        case let .symlink(symlink):
            print(await symlink.target.value)
        }
    }

    func testGitHubClient() async throws {
        let api = GitHubApi()
        let storage: Storage<GitHubCacheKey, String> = try Storage(
            diskConfig: GitHubCachedDataFetcherFactory.DefaultCacheDiskConfig,
            memoryConfig: GitHubCachedDataFetcherFactory.DefaultCacheMemoryConfig,
            transformer: TransformerFactory.forCodable(ofType: String.self)
        )

        defer { try? storage.removeAll() }

        let client = GitHubClient(
            gitHubApi: api,
            cachedDataFetcherFactory: GitHubCachedDataFetcherFactory(storage: storage)
        )

        let result = await client.getRepository(owner: "kubernetes", name: "kubernetes")

        switch result {
        case let .failure(err):
            XCTFail("API request failed with error: \(err)")

        case let .success(res):
            let value = await res.tree.rootDir.contents.value

            switch value {
            case let .success(contents):
                await contents.concurrentForEach { content in
                    await self.traverseGitContent(content: content)
                }

            case let .failure(err):
                XCTFail("Retriving contents of root dir failed with error: \(err)")
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
            let value = await file.contents.value
            if case let .failure(err) = value {
                indentedPrint("ERROR for file: \(content.name)")
                indentedPrint(err)
            } else if case let .success(contents) = value {
                print("\nFile path: \(content.path.string)")
                print(contents.split(separator: "\n")[safe: 0..<3].joined(separator: "\n"))
                print("")
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
