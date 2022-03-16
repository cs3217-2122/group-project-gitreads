//
//  Path.swift
//  GitReads

struct Path: Hashable {

    static let root = Path(components: [], separator: "/")

    let pathComponents: [String]
    let separator: Character

    /// String representation of the path
    let string: String

    /// Initializes the path from the string representation of the full path, ie. "/a/b/c"
    init(string: String, separator: Character = "/") {
        self.pathComponents = string.split(separator: separator).map { String($0) }
        self.separator = separator
        self.string = string
    }

    init(components: [String], separator: Character = "/") {
        self.pathComponents = components
        self.separator = separator
        self.string = components.joined(separator: String(separator))
    }

    init(components: String..., separator: Character = "/") {
        self.init(components: components, separator: separator)
    }

    /// Returns the last path component, ie for a path "/a/b/c", returns "c'".
    /// Returns nil for an empty path.
    var lastPathComponent: String? {
        pathComponents.last
    }

    /// Returns the parent path component, ie for a path "/a/b/c", returns a path of "/a/b".
    /// Returns nil for an empty path.
    var parentPath: Path? {
        if pathComponents.isEmpty {
            return nil
        }

        return Path(
            components: Array(pathComponents[0..<pathComponents.count - 1]),
            separator: separator
        )
    }

    var numPathComponents: Int {
        pathComponents.count
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pathComponents)
        hasher.combine(separator)
    }
}
