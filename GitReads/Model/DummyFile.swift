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

        let lines = code.map {
            Line(
                tokens: $0.split(separator: " ").map { Token(type: .keyword, value: String($0)) },
                indentLevel: 0
            )
        }
        let result = File(name: "TEST", language: "swift", declarations: [], lines: lines)
        return result
    }
}
