//
//  CDeclarationParser.swift
//  GitReads
//
//  Created by Liu Zimu on 6/4/22.
//

class CDeclarationParser {

    static func getDeclarations(rootNode: ASTNode?, fileString: String) -> [Declaration] {
        guard let rootNode = rootNode else {
            return []
        }

        let lines = TokenConverter.breakStringByline(fileString)
        return getVariableDeclarations(node: rootNode, lines: lines)
        + getFunctionDeclarations(node: rootNode, lines: lines)
        + getStructDeclarations(node: rootNode, lines: lines)
        + getTypeDeclarations(node: rootNode, lines: lines)
        + getPreprocDeclarations(node: rootNode, lines: lines)
    }

    static func getVariableDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        var declarations = [Declaration]()
        for child in node.children {
            declarations += getVariableDeclarations(node: child, lines: lines)
        }

        guard node.type.contains("declaration") else {
            return declarations
        }

        for child in node.children where child.type.contains("declarator")
        || child.type.contains("identifier") {
            let identifier = getIdentifier(node: child, lines: lines)
            if !identifier.isEmpty {
                declarations.append(
                    VariableDeclaration(start: child.start,
                                        end: child.end,
                                        identifier: identifier)
                )
            }
        }

        return declarations
    }

    static func getFunctionDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        guard node.type == "function_definition" else {
            var declarations = [Declaration]()
            for child in node.children {
                declarations += getFunctionDeclarations(node: child, lines: lines)
            }

            return declarations
        }

        var identifier = ""
        for child in node.children where child.type.contains("declarator") {
            identifier = getIdentifier(node: child, lines: lines)
        }

        return identifier.isEmpty ? [] : [
            FunctionDeclaration(start: node.start,
                                end: node.end,
                                identifier: identifier)
        ]
    }

    static func getStructDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        guard node.type == "struct_specifier"
                && node.children.count == 3
                && node.children[1].type == "type_identifier"
                && node.children[2].type == "field_declaration_list"
        else {
            var declarations = [Declaration]()
            for child in node.children {
                declarations += getStructDeclarations(node: child, lines: lines)
            }

            return declarations
        }

        let child = node.children[1]
        let identifier = String(TokenConverter.getTokenString(lines: lines,
                                                              start: child.start,
                                                              end: child.end)[0])

        return [
            StructDeclaration(start: node.start,
                              end: node.end,
                              identifier: identifier)
        ]
    }

    static func getTypeDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        guard node.type == "type_definition" else {
            var declarations = [Declaration]()
            for child in node.children {
                declarations += getTypeDeclarations(node: child, lines: lines)
            }

            return declarations
        }

        var identifier = ""
        for child in node.children where child.type == "type_identifier" {
            identifier = String(TokenConverter.getTokenString(lines: lines,
                                                              start: child.start,
                                                              end: child.end)[0])
        }

        return identifier.isEmpty ? [] : [
            TypeDeclaration(start: node.start,
                            end: node.end,
                            identifier: identifier)
        ]
    }

    static func getPreprocDeclarations(node: ASTNode, lines: [String.UTF8View]) -> [Declaration] {
        guard node.type == "preproc_def" || node.type == "preproc_function_def" else {
            var declarations = [Declaration]()
            for child in node.children {
                declarations += getPreprocDeclarations(node: child, lines: lines)
            }

            return declarations
        }

        var identifier = ""
        for child in node.children where child.type == "identifier" {
            identifier = String(TokenConverter.getTokenString(lines: lines,
                                                              start: child.start,
                                                              end: child.end)[0])
        }

        return identifier.isEmpty ? [] : [
            PreprocDeclaration(start: node.start,
                               end: node.end,
                               identifier: identifier)
        ]
    }

    private static func getIdentifier(node: ASTNode, lines: [String.UTF8View]) -> String {
        if node.type.contains("identifier") {
            return String(TokenConverter.getTokenString(lines: lines,
                                                        start: node.start,
                                                        end: node.end)[0])
        }

        if node.type.contains("declarator") {
            for child in node.children {
                let identifier = getIdentifier(node: child, lines: lines)
                if !identifier.isEmpty {
                    return identifier
                }
            }
        }

        return ""
    }
}
