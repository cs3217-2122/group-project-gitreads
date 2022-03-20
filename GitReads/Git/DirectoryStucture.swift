//
//  DirectoryStructure.swift
//  GitReads

struct DirectoryStucture<T> {
    let elements: [T]

    private(set) var pathToElementIdx: [Path: Int] = [:]

    /// directoryStructure is a dictionary keyed by a parent path mapped to an array
    /// of the indices of all of its children elements.
    private(set) var directoryStructure: [Path: [Int]] = [:]

    /// Takes in a list of elements, as well as a getter function to retrieve a `Path` from each element.
    /// We assume that the paths of each element is "well-formed", ie. for every path there is
    /// a way to traverse to that path from the root of the directory. Elements with paths that are not
    /// well-formed will be skipped.
    init(elements: [T], getPath: (T) -> Path) {
        self.elements = elements
        let enumerated = elements.enumerated()

        // group the elements by number of path components, then
        // add each element's index under its parent's path to
        // the directory structure dictionary, starting from the
        // smallest number of path cimponents
        Array(Dictionary(grouping: enumerated) {
            getPath($0.element).numPathComponents
        })
        .sorted { $0.key < $1.key }
        .forEach { numPathComponents, items in
            if numPathComponents == 0 {
                return
            }

            for (idx, item) in items {
                let path = getPath(item)
                // we know that the parent path is defined since the number of path
                // components is more than 0
                let parentPath = path.parentPath!

                // if there is no actual parent directory for this element, then
                // we skip it. we don't skip if the parent path is the root however,
                // as we consider the root a special case which does not need to have
                // an actual element
                if parentPath != .root && pathToElementIdx[parentPath] == nil {
                    continue
                }

                pathToElementIdx[path] = idx
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
