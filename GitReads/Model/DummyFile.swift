//
//  DummyFile.swift
//  GitReads
//
//  Created by Zhou Jiahao on 14/3/22.
//

// swiftlint:disable function_body_length
import Foundation

class DummyFile {
    static func getFile() -> File {
        let code = ["class PhysicsEngine {",
                    "    var moveableObjects: [MoveableObject] = []",
                    "    var fixedObjects: [FixedObject] = []",
                    "",
                    "    func update(gravity: Double, fps: Double) {",
                    "        collideObjects = []",
                    "        for moveableObject in moveableObjects {",
                    "            moveableObject.update(gravity: gravity, fps: fps)",
                    "            if let object = getCollide(movable: moveableObject) {",
                    "                collideObjects.append(object)",
                    "            }",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "class PhysicsEngine {",
                    "    var moveableObjects: [MoveableObject] = []",
                    "    var fixedObjects: [FixedObject] = []",
                    "",
                    "    func update(gravity: Double, fps: Double) {",
                    "        collideObjects = []",
                    "        for moveableObject in moveableObjects {",
                    "            moveableObject.update(gravity: gravity, fps: fps)",
                    "            if let object = getCollide(movable: moveableObject) {",
                    "                collideObjects.append(object)",
                    "            }",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "    var moveableObjects: [MoveableObject] = []",
                    "    var fixedObjects: [FixedObject] = []",
                    "",
                    "    func update(gravity: Double, fps: Double) {",
                    "        collideObjects = []",
                    "        for moveableObject in moveableObjects {",
                    "            moveableObject.update(gravity: gravity, fps: fps)",
                    "            if let object = getCollide(movable: moveableObject) {",
                    "                collideObjects.append(object)",
                    "            }",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "    var moveableObjects: [MoveableObject] = []",
                    "    var fixedObjects: [FixedObject] = []",
                    "",
                    "    func update(gravity: Double, fps: Double) {",
                    "        collideObjects = []",
                    "        for moveableObject in moveableObjects {",
                    "            moveableObject.update(gravity: gravity, fps: fps)",
                    "            if let object = getCollide(movable: moveableObject) {",
                    "                collideObjects.append(object)",
                    "            }",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "    var moveableObjects: [MoveableObject] = []",
                    "    var fixedObjects: [FixedObject] = []",
                    "",
                    "    func update(gravity: Double, fps: Double) {",
                    "        collideObjects = []",
                    "        for moveableObject in moveableObjects {",
                    "            moveableObject.update(gravity: gravity, fps: fps)",
                    "            if let object = getCollide(movable: moveableObject) {",
                    "                collideObjects.append(object)",
                    "            }",
                    "        }",
                    "    }",
                    "}",
                    "" ]

        let lines = code.enumerated().map { idx, line in
            Line(
                lineNumber: idx,
                tokens: line.split(separator: " ").map { val in
                    Token(type: .keyword, value: String(val), startIdx: 0, endIdx: val.count)
                }
            )
        }
        let lazyParseOutput = LazyDataSource(
            value: ParseOutput(fileContents: code.joined(separator: "\n"),
                               lines: lines,
                               declarations: [],
                               scopes: []
            )
        )

        let result = File(
            path: Path(components: "TEST"),
            sha: "deadbeef",
            language: .others,
            parseOutput: lazyParseOutput
        )
        return result
    }
}
