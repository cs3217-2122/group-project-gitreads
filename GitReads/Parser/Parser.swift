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

    func parse(gitRepo: GitRepo) async -> Result<Repo, Error> {
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

    private func parse(gitDir: GitDirectory, path: Path) async -> Result<Directory, Error> {
        await gitDir.contents.value
            .asyncMap { contents in
                Directory(files: await parseFilesInDir(contents),
                          directories: await parseDirectoriesInDir(contents),
                          path: path)
            }
    }

    private func parseFilesInDir(_ dir: [GitContent]) async -> [File] {
        dir.compactMap { content in
            guard case let .file(file) = content.type else {
                return nil
            }

            return parse(gitFile: file, path: content.path, name: content.name)
        }
    }

    private func parseDirectoriesInDir(_ dir: [GitContent]) async -> [Directory] {
        await withTaskGroup(of: Result<Directory, Error>.self, returning: [Directory].self) { group in
            for content in dir {
                guard case let .directory(dir) = content.type else {
                    continue
                }

                group.addTask {
                    await self.parse(gitDir: dir, path: content.path)
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

    private func parse(gitFile: GitFile, path: Path, name: String) -> File {
        let language = detectLanguage(name: name)
        let parseOutput: LazyDataSource<ParseOutput> = gitFile.contents.flatMap { currentFile in
            do {
                let result = try await FileParser.parseFile(fileString: currentFile, language: language)
                return .success(ParseOutput(fileContents: currentFile, lines: result))
            } catch {
                return .failure(error)
            }
        }
        return File(path: path, language: language, declarations: [], parseOutput: parseOutput)
    }

    private func detectLanguage(name: String) -> Language {
        let type = getFileType(name)
        let language = Language(rawValue: type)
        if let language = language {
            return language
        }

        return Language.others
    }

    private func getFileType(_ fileName: String) -> String {
        let type = fileName.split(separator: ".").last
        if type != nil {
            return String(type!)
        } else {
            return ""
        }
    }

    func readFile(_ filePath: String) -> String {
        do {
            return try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}
