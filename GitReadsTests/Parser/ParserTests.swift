//
//  ParserTests.swift
//  GitReadsTests
//
//  Created by Wong Lok Cheng on 14/4/22.
//

import XCTest
@testable import GitReads

class ParserTests: XCTestCase {

    func testExample() async throws {
        let file = """
                   int main() {
                       int a = 5;
                   }

                   struct Person {
                     char name[50];
                     int citNo;
                     float salary;
                   };

                   typedef struct Point{
                     int x;
                     int y;
                   } Point;

                   int add(int a, int b) {
                       return a + b;
                   }
                   """

        let jsonTree = try await WebApiClient.getAstJson(
            apiPath: Constants.webParserApiAstPath,
            fileString: file,
            language: Language.c
        )

        guard let jsonTree = jsonTree else {
            XCTFail("nil lol")
            return
        }

        let astTree = ASTNode.buildAstFromJson(jsonTree: jsonTree)
        guard let astTree = astTree else {
            XCTFail("no ast lol")
            return
        }

        let typeKey = "type"
        let identifierKey = "identifier"

        let matcher = MatchAnyOf {
            Match(type: .contains("declaration"), key: typeKey) {
                MatchAnyOf {
                    Match(type: .contains("identifier"), key: identifierKey)
                    Match(type: .contains("declarator")) {
                        Match(type: .contains("identifier"), key: identifierKey)
                    }
                }
            }
            Match(type: .exact("function_definition"), key: typeKey) {
                Match(type: .contains("declarator")) {
                    Match(type: .contains("identifier"), key: identifierKey)
                }
            }
            Match(type: .exact("struct_specifier"), key: typeKey) {
                Match(type: .exact("type_identifier"), key: identifierKey)
            }
            Match(type: .exact("type_definition"), key: typeKey) {
                Match(type: .exact("type_identifier"), key: identifierKey)
            }
            Match(type: .oneOf(["preproc_def", "preprof_function_def"]), key: typeKey) {
                Match(type: .exact("identifier"), key: identifierKey)
            }
        }

        let astQuerier = ASTQuerier(root: astTree)
        let query = Query(matcher: matcher) { result -> Declaration? in
            let type = result[typeKey]!.type
            let node = result[identifierKey]!
            let value = String(TokenConverter.getTokenString(
                lines: file.components(separatedBy: "\n").map { String($0).utf8 },
                start: [node.start.line, node.start.char],
                end: [node.end.line, node.end.char]
            )[0])

            switch type {
            case type where type.contains("declaration"):
                return VariableDeclaration(
                    start: [node.start.line, node.start.char],
                    end: [node.end.line, node.end.char],
                    identifier: value
                )
            case "function_definition":
                return FunctionDeclaration(
                    start: [node.start.line, node.start.char],
                    end: [node.end.line, node.end.char],
                    identifier: value
                )
            case "struct_specifier":
                return StructDeclaration(
                    start: [node.start.line, node.start.char],
                    end: [node.end.line, node.end.char],
                    identifier: value
                )
            case "type_definition":
                return TypeDeclaration(
                    start: [node.start.line, node.start.char],
                    end: [node.end.line, node.end.char],
                    identifier: value
                )
            case "preproc_def", "preproc_function_def":
                return PreprocDeclaration(
                    start: [node.start.line, node.start.char],
                    end: [node.end.line, node.end.char],
                    identifier: value
                )
            default:
                return nil
            }
        }

        let queryResult = astQuerier.doQuery(query)
        for res in queryResult {
            print(res)
        }
    }
}
