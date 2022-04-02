//
//  Parser.swift
//  GitReads
//
//  Created by Liu Zimu on 15/3/22.
//

import Foundation
import SwiftTreeSitter
import SwiftUI

class Parser {

    static func parse(gitRepo: GitRepo) async -> Result<Repo, Error> {
        await parse(gitDir: gitRepo.tree.rootDir, path: .root).map { rootDir in
            Repo(name: gitRepo.name,
                 owner: gitRepo.owner,
                 description: gitRepo.description,
                 platform: gitRepo.platform,
                 defaultBranch: gitRepo.defaultBranch,
                 branches: gitRepo.branches,
                 currBranch: gitRepo.currBranch,
                 root: rootDir,
                 htmlURL: gitRepo.htmlURL
            )
        }
    }

    private static func parse(gitDir: GitDirectory, path: Path) async -> Result<Directory, Error> {
        await gitDir.contents.value
            .asyncMap { contents in
                Directory(files: await parseFilesInDir(contents),
                          directories: await parseDirectoriesInDir(contents),
                          path: path)
            }
    }

    private static func parseFilesInDir(_ dir: [GitContent]) async -> [File] {
        dir.compactMap { content in
            guard case let .file(file) = content.type else {
                return nil
            }

            return parse(gitFile: file, path: content.path, name: content.name)
        }
    }

    private static func parseDirectoriesInDir(_ dir: [GitContent]) async -> [Directory] {
        await withTaskGroup(of: Result<Directory, Error>.self, returning: [Directory].self) { group in
            for content in dir {
                guard case let .directory(dir) = content.type else {
                    continue
                }

                group.addTask {
                    await parse(gitDir: dir, path: content.path)
                }
            }

            var directories: [Directory] = []
            for await value in group {
                // TODO: handle errors
                guard case let .success(value) = value else {
                    continue
                }

                directories.append(value)
            }

            return directories
        }
    }

    private static func parse(gitFile: GitFile, path: Path, name: String) -> File {
        let language = detectLanguage(name: name)
        let lines: LazyDataSource<[Line]> = gitFile.contents.flatMap { currentFile in
            do {
                let result = try await FileParser.parseFile(fileString: currentFile, language: language)
                return .success(result)
            } catch {
                return .failure(error)
            }
        }
        return File(path: path, language: language, declarations: [], lines: lines)
    }

    private static func detectLanguage(name: String) -> Language {
        let type = getFileType(name)
        let language = Language(rawValue: type)
        if let language = language {
            return language
        }

        return Language.others
    }

    private static func getFileType(_ fileName: String) -> String {
        let type = fileName.split(separator: ".").last
        if type != nil {
            return String(type!)
        } else {
            return ""
        }
    }
}
