//
//  Parser.swift
//  GitReads
//
//  Created by Liu Zimu on 15/3/22.
//

import Foundation
import SwiftTreeSitter

class Parser {

    private(set) var sourceCode: String
    private(set) var language: STSLanguage.PrebundledLanguage
    private(set) var tree: STSTree
    private(set) var leafNodes: [STSNode] = []

    init(sourceCode: String, language: STSLanguage.PrebundledLanguage) {
        self.sourceCode = sourceCode
        self.language = language
        tree = Parser.parse(sourceCode: sourceCode, language: language)
        buildLeafNodes()
    }

    convenience init(filePath: String, language: STSLanguage.PrebundledLanguage) {
        self.init(sourceCode: Parser.readFile(filePath), language: language)
    }

    static func parse(gitRepo: GitRepo) async -> Result<Repo, Error> {
        await parse(gitDir: gitRepo.tree.rootDir, path: .root).map { rootDir in
            Repo(root: rootDir)
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
        let lines: LazyDataSource<[Line]> = gitFile.contents.map { currentFile in
            switch language {
            case .Java:
                let parser = DummyFileParser()
                return parser.parse(fileString: currentFile)
            }
        }
        return File(path: path, language: language, declarations: [], lines: lines)
    }

    private static func detectLanguage(name: String) -> Language {
        .Java
    }

    // Return content of a file as a string
    private static func readFile(_ filePath: String) -> String {
        do {
            return try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        } catch {
            fatalError(Constants.readingFileError)
        }
    }

    // Return a syntax tree from given source code
    private static func parse(sourceCode: String, language: STSLanguage.PrebundledLanguage) -> STSTree {
        let lang: STSLanguage
        do {
            lang = try STSLanguage(fromPreBundle: language)
        } catch {
            fatalError(Constants.parsingError)
        }

        let parser = STSParser(language: lang)
        return parser.parse(string: sourceCode, oldTree: nil)!
    }

    // Return all the leaf nodes of the given syntax tree
    private func buildLeafNodes() {
        buildLeafNodeHelper(node: tree.rootNode)
    }

    // Utility method to recursively find leaf nodes
    private func buildLeafNodeHelper(node: STSNode) {
        for childNode in node.children() {
            if childNode.childCount == 0 {
                leafNodes.append(childNode)
            } else {
                buildLeafNodeHelper(node: childNode)
            }
        }
    }

    // Return source code at the given location
    private func getCode(_ startByte: Int, _ endByte: Int) -> String {
        let start = sourceCode.index(sourceCode.startIndex, offsetBy: startByte)
        let end = sourceCode.index(sourceCode.endIndex, offsetBy: endByte - sourceCode.count)
        let range = start..<end
        return String(sourceCode[range])
    }

    // Convert a node to a token
    /*
    private func tokenize(node: STSNode) -> Token {
    }
     */

    // Get the token type of a node
    private func getType(node: STSNode) -> TokenType {
        guard !isPunctuation(node) else {
            return .punctuation
        }

        switch node.type {
        case "string_fragment":
            return .string
        case "number":
            return .number
        case "function":
            return .function
        case "identifier":
            return .identifier
        case "property_identifier":
            return .propertyIdentifier
        case "line_comment":
            return .comment
        default:
            return .keyword
        }
    }

    // Check whether a node is a punctuation
    private func isPunctuation(_ node: STSNode) -> Bool {
        for letter in node.type where letter.isLetter {
            return false
        }

        return true
    }

    static func tryParser() {
        let filePath = "/Users/niclausliu/Desktop/CS3217/Final project/Code/sample3.java"
        let parser = Parser(filePath: filePath, language: .java)
        print(parser.tree.rootNode.sExpressionString!)
        parser.leafNodes.forEach {
            print("type:\t\($0.type)")
            // print("start point:\t\($0.startPoint)")
            // print("end point:\t\($0.endPoint)")
            // print("start byte:\t\($0.startByte)")
            // print("end byte:\t\($0.endByte)")
        }
        parser.leafNodes.forEach {
            print(parser.getCode(Int($0.startByte), Int($0.endByte)), terminator: "")
        }

        /*
         let callExpression = tree.rootNode.child(at: 1).firstChild(forOffset: 0).firstChild(forOffset: 0).child(at: 3)
         print("type:\t\(callExpression.type)")
         print("start point:\t\(callExpression.startPoint)")
         print("end point:\t\(callExpression.endPoint)")
         print("start byte:\t\(callExpression.startByte)")
         print("end byte:\t\(callExpression.endByte)")
         */
    }
}
