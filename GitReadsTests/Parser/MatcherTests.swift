//
//  MatcherTests.swift
//  GitReadsTests

import XCTest
@testable import GitReads

// swiftlint:disable function_body_length type_body_length file_length
class MatcherTests: XCTestCase {

    func testC() async throws {
        let c = #"""
                typedef struct {
                  int           verbose;
                  uint32_t      flags;
                  FILE         *input;
                } options_t;

                struct address
                {
                   char name[50];
                   char street[100];
                   char city[50];
                };

                int main(int argc, char **argv) {
                    printf("argc = %d\n", argc);
                    for(int ndx = 0; ndx != argc; ++ndx)
                        printf("argv[%d] --> %s\n", ndx,argv[ndx]);
                    printf("argv[argc] = %p\n", (void*)argv[argc]);
                }
                """#

        let rootNode = try await CParser.getAstFromApi(fileString: c)
        guard let rootNode = rootNode else {
            XCTFail("root node is nil")
            return
        }

        let scopes = Set(CParser.getScopes(root: rootNode))

        let expected = Set([
            Scope(
                prefixStart: Scope.Index(line: 0, char: 8),
                prefixEnd: Scope.Index(line: 0, char: 16),
                end: Scope.Index(line: 4, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 6, char: 0),
                prefixEnd: Scope.Index(line: 7, char: 1),
                end: Scope.Index(line: 11, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 13, char: 0),
                prefixEnd: Scope.Index(line: 13, char: 33),
                end: Scope.Index(line: 18, char: 1)
            )
        ])

        XCTAssertEqual(expected, scopes, """

                                         Missing elements: \(expected.subtracting(scopes))
                                         Extra elements: \(scopes.subtracting(expected))
                                         """
        )
    }

    func testPython() async throws {
        let python = #"""
                     x = lambda a,b: \
                         b - a if a <= b else \
                         a*b

                     class Dog:
                         def __init__(self, name):
                             self.name = name
                             self.tricks = []    # creates a new empty list for each dog

                         def add_trick(self, trick):
                             self.tricks.append(trick)

                         @abstractmethod
                         def hello():
                             pass

                     def add(a, b):
                         def help():
                             return 1
                         return a + b + help()
                     """#

        let rootNode = try await PythonParser.getAstFromApi(fileString: python)
        guard let rootNode = rootNode else {
            XCTFail("root node is nil")
            return
        }

        let scopes = Set(PythonParser.getScopes(root: rootNode))

        let expected = Set([
            Scope(
                prefixStart: Scope.Index(line: 0, char: 4),
                prefixEnd: Scope.Index(line: 0, char: 15),
                end: Scope.Index(line: 2, char: 7)
            ),
            Scope(
                prefixStart: Scope.Index(line: 4, char: 0),
                prefixEnd: Scope.Index(line: 4, char: 10),
                end: Scope.Index(line: 14, char: 12)
            ),
            Scope(
                prefixStart: Scope.Index(line: 5, char: 4),
                prefixEnd: Scope.Index(line: 5, char: 29),
                end: Scope.Index(line: 7, char: 24)
            ),
            Scope(
                prefixStart: Scope.Index(line: 9, char: 4),
                prefixEnd: Scope.Index(line: 9, char: 31),
                end: Scope.Index(line: 10, char: 33)
            ),
            Scope(
                prefixStart: Scope.Index(line: 13, char: 4),
                prefixEnd: Scope.Index(line: 13, char: 16),
                end: Scope.Index(line: 14, char: 12)
            ),
            Scope(
                prefixStart: Scope.Index(line: 16, char: 0),
                prefixEnd: Scope.Index(line: 16, char: 14),
                end: Scope.Index(line: 19, char: 25)
            ),
            Scope(
                prefixStart: Scope.Index(line: 17, char: 4),
                prefixEnd: Scope.Index(line: 17, char: 15),
                end: Scope.Index(line: 18, char: 16)
            )
        ])

        XCTAssertEqual(expected, scopes, """

                                         Missing elements: \(expected.subtracting(scopes))
                                         Extra elements: \(scopes.subtracting(expected))
                                         """
        )
    }

    func testGolang() async throws {
        let golang = """
                     package main

                     import (
                         "fmt"
                     )

                     func main() {
                         var (
                             a = "hello"
                             b = "world"
                             c = []struct {
                                 hi       int
                                 expected int
                             }{
                                 {1, 2},
                             }
                             d = map[int]interface {
                                 read()
                             }{}
                         )

                         fmt.Printf("%s %s %v %v!", a, b, c, d)
                     }

                     type Lol struct {
                         Hello string
                         World string
                     }

                     func (l *Lol) print() {
                         fmt.Printf("%s, %s", l.Hello, l.World)
                     }

                     type Lmao interface {
                         Sum(a, b int) int
                         Close()
                     }
                     """

        let rootNode = try await GoParser.getAstFromApi(fileString: golang)
        guard let rootNode = rootNode else {
            XCTFail("root node is nil")
            return
        }

        let scopes = Set(GoParser.getScopes(root: rootNode))

        let expected = Set([
            Scope(
                prefixStart: Scope.Index(line: 6, char: 0),
                prefixEnd: Scope.Index(line: 6, char: 13),
                end: Scope.Index(line: 22, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 10, char: 14),
                prefixEnd: Scope.Index(line: 10, char: 22),
                end: Scope.Index(line: 13, char: 9)
            ),
            Scope(
                prefixStart: Scope.Index(line: 16, char: 20),
                prefixEnd: Scope.Index(line: 16, char: 31),
                end: Scope.Index(line: 18, char: 9)
            ),
            Scope(
                prefixStart: Scope.Index(line: 24, char: 0),
                prefixEnd: Scope.Index(line: 24, char: 17),
                end: Scope.Index(line: 27, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 29, char: 0),
                prefixEnd: Scope.Index(line: 29, char: 23),
                end: Scope.Index(line: 31, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 33, char: 0),
                prefixEnd: Scope.Index(line: 33, char: 21),
                end: Scope.Index(line: 36, char: 1)
            )
        ])

        XCTAssertEqual(expected, scopes, """

                                         Missing elements: \(expected.subtracting(scopes))
                                         Extra elements: \(scopes.subtracting(expected))
                                         """
        )
    }

    func testJavascript() async throws {
        let javascript = """
                         class User {
                           constructor(name) {
                             this.name = name;
                           }

                           sayHi() {
                             alert(this.name);
                           }
                         }

                         function things() {
                             return {
                                 hello() {
                                     console.log("hello")
                                 },
                                 squares: [1, 2, 3].map(x => { return x * x }),
                                 cubes: [1, 2, 3].map((x) => x * x * x)
                             }
                         }

                         let myAdd = function(a, b) {
                             return a + b;
                         }
                         """

        let rootNode = try await JavascriptParser.getAstLocally(fileString: javascript)
        let scopes = Set(JavascriptParser.getScopes(root: rootNode))

        let expected = Set([
            Scope(
                prefixStart: Scope.Index(line: 0, char: 0),
                prefixEnd: Scope.Index(line: 0, char: 12),
                end: Scope.Index(line: 8, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 1, char: 2),
                prefixEnd: Scope.Index(line: 1, char: 21),
                end: Scope.Index(line: 3, char: 3)
            ),
            Scope(
                prefixStart: Scope.Index(line: 5, char: 2),
                prefixEnd: Scope.Index(line: 5, char: 11),
                end: Scope.Index(line: 7, char: 3)
            ),
            Scope(
                prefixStart: Scope.Index(line: 10, char: 0),
                prefixEnd: Scope.Index(line: 10, char: 19),
                end: Scope.Index(line: 18, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 12, char: 8),
                prefixEnd: Scope.Index(line: 12, char: 17),
                end: Scope.Index(line: 14, char: 9)
            ),
            Scope(
                prefixStart: Scope.Index(line: 15, char: 31),
                prefixEnd: Scope.Index(line: 15, char: 37),
                end: Scope.Index(line: 15, char: 52)
            ),
            Scope(
                prefixStart: Scope.Index(line: 16, char: 29),
                prefixEnd: Scope.Index(line: 16, char: 35),
                end: Scope.Index(line: 16, char: 45)
            ),
            Scope(
                prefixStart: Scope.Index(line: 20, char: 12),
                prefixEnd: Scope.Index(line: 20, char: 28),
                end: Scope.Index(line: 22, char: 1)
            )
        ])

        XCTAssertEqual(expected, scopes, """

                                         Missing elements: \(expected.subtracting(scopes))
                                         Extra elements: \(scopes.subtracting(expected))
                                         """
        )
    }

    func testJSON() async throws {
        let json = """
                   {
                       "hello": "world",
                       "id": 123,
                       "arr": [
                           {
                               "test": null
                           },
                           {
                               "ok": []
                           }
                       ]
                   }
                   """

        let rootNode = try await JsonParser.getAstLocally(fileString: json)
        let scopes = Set(JsonParser.getScopes(root: rootNode))

        let expected = Set([
            Scope(
                prefixStart: Scope.Index(line: 0, char: 0),
                prefixEnd: Scope.Index(line: 0, char: 1),
                end: Scope.Index(line: 11, char: 1)
            ),
            Scope(
                prefixStart: Scope.Index(line: 3, char: 11),
                prefixEnd: Scope.Index(line: 3, char: 12),
                end: Scope.Index(line: 10, char: 5)
            ),
            Scope(
                prefixStart: Scope.Index(line: 4, char: 8),
                prefixEnd: Scope.Index(line: 4, char: 9),
                end: Scope.Index(line: 6, char: 9)
            ),
            Scope(
                prefixStart: Scope.Index(line: 7, char: 8),
                prefixEnd: Scope.Index(line: 7, char: 9),
                end: Scope.Index(line: 9, char: 9)
            ),
            Scope(
                prefixStart: Scope.Index(line: 8, char: 18),
                prefixEnd: Scope.Index(line: 8, char: 19),
                end: Scope.Index(line: 8, char: 20)
            )
        ])

        XCTAssertEqual(expected, scopes, """

                                         Missing elements: \(expected.subtracting(scopes))
                                         Extra elements: \(scopes.subtracting(expected))
                                         """
        )
    }

    func testHTML() async throws {
        let html = """
                   <form role="form">
                     <div class="form-group">
                       <label for="email">
                           Email address: <br>
                       </label>
                       <input type="email" class="form-control" id="email">
                     </div>
                     <button type="submit" class="btn btn-default">Submit</button>
                   </form>
                   """

        let rootNode = try await HtmlParser.getAstLocally(fileString: html)
        let scopes = Set(HtmlParser.getScopes(root: rootNode))

        let expected = Set([
            Scope(
                prefixStart: Scope.Index(line: 0, char: 0),
                prefixEnd: Scope.Index(line: 0, char: 18),
                end: Scope.Index(line: 8, char: 7)
            ),
            Scope(
                prefixStart: Scope.Index(line: 1, char: 2),
                prefixEnd: Scope.Index(line: 1, char: 26),
                end: Scope.Index(line: 6, char: 8)
            ),
            Scope(
                prefixStart: Scope.Index(line: 2, char: 4),
                prefixEnd: Scope.Index(line: 2, char: 23),
                end: Scope.Index(line: 4, char: 12)
            ),
            Scope(
                prefixStart: Scope.Index(line: 7, char: 2),
                prefixEnd: Scope.Index(line: 7, char: 48),
                end: Scope.Index(line: 7, char: 63)
            )
        ])

        XCTAssertEqual(expected, scopes, """

                                         Missing elements: \(expected.subtracting(scopes))
                                         Extra elements: \(scopes.subtracting(expected))
                                         """
        )
    }
}
