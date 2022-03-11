//
//  CodeView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct CodeView: View {
    var file = ["class PhysicsEngine {",
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
                "",]
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<file.count, id: \.self) { line in
                    HStack {
                        Text(String(line + 1))
                            .padding(.leading) // need to address the width problem
                        LineView(text: file[line])
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView()
.previewInterfaceOrientation(.portrait)
    }
}
