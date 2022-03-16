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

    public static func parse(gitRepo: GitRepo) async -> Repo? {

        if let rootDir = await parse(gitDir: gitRepo.tree.rootDir, name: "root") {
            return Repo(root: rootDir)
        }
        return nil
    }

    private static func parse(gitDir: GitDirectory, name: String) async -> Directory? {
        if let currentDir = try? await gitDir.contents.value.get() {
            var directory = Directory(files: [], directories: [], name: name)

            for content in currentDir {
                switch content.type {
                case .directory(let dir):
                    if let dir = await parse(gitDir: dir, name: content.name) {
                        directory.directories.append(dir)
                    }
                case .file(let file):
                    if let file = await parse(gitFile: file, name: content.name) {
                        directory.files.append(file)
                    }
                default:
                    break
                }
            }

            return directory
        }
        return nil
    }

    private static func parse(gitFile: GitFile, name: String) async -> File? {
        if let currentFile = try? await gitFile.contents.value.get() {
            let language = detectLanguage(name: name)

            switch language {
            case .Java:
                let parser = DummyFileParser()
                return parser.parse(fileString: currentFile, name: name)
            }
        }
        return nil
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
