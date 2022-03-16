//
//  DirectoryStructure.swift
//  GitReads

struct DirectoryStucture<T> {
    let elements: [T]

    private(set) var pathToElementIdx: [Path: Int] = [:]

    /// directoryStructure is a dictionary keyed by a parent path mapped to an array
    /// of the indices of all of its children elements.
    private(set) var directoryStructure: [Path: [Int]] = [:]

    init(elements: [T], getPath: (T) -> Path) {
        self.elements = elements
        let enumerated = elements.enumerated()

        for (idx, element) in enumerated {
            pathToElementIdx[getPath(element)] = idx
        }

        // group the elements by number of path components, then
        // add each element's index under its parent's path to
        // the directory structure dictionary, starting from the
        // smallest number of path cimponents
        Array(Dictionary(grouping: enumerated) {
            getPath($0.element).numPathComponents
        })
        .sorted { $0.key < $1.key }
        .forEach { numPathComponents, objects in
            if numPathComponents == 0 {
                return
            }

            for (idx, object) in objects {
                // we know that the parent path is defined since the number of path
                // components is more than 0
                let parentPath = getPath(object).parentPath!
                directoryStructure[parentPath, default: []].append(idx)
            }
        }
    }

    func element(at path: Path) -> T? {
        guard let idx = pathToElementIdx[path] else {
            return nil
        }

        return elements[idx]
    }

    func childrenUnder(path: Path) -> [T] {
        let indices = directoryStructure[path] ?? []
        return indices.map { elements[$0] }
    }
}
