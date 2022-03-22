//
//  GitTree.swift
//  GitReads

struct GitTree {

    typealias GitContentFetcher = (
        _ object: GitObject,
        _ commitSha: String
    ) -> GitContent

    let commitSha: String

    private let gitObjects: [GitObject]
    private let fileContentFetcher: GitContentFetcher
    private let symlinkContentFetcher: GitContentFetcher
    private let submoduleContentFetcher: GitContentFetcher

    private let directoryStructure: DirectoryStucture<GitObject>

    init(
        commitSha: String,
        gitObjects: [GitObject],
        fileContentFetcher: @escaping GitContentFetcher,
        symlinkContentFetcher: @escaping GitContentFetcher,
        submoduleContentFetcher: @escaping GitContentFetcher
    ) {
        self.commitSha = commitSha
        self.gitObjects = gitObjects
        self.fileContentFetcher = fileContentFetcher
        self.symlinkContentFetcher = symlinkContentFetcher
        self.submoduleContentFetcher = submoduleContentFetcher

        self.directoryStructure = DirectoryStucture(elements: gitObjects, getPath: { $0.path })
    }

    var rootDir: GitDirectory { directory(at: .root) }

    ///  Returns the GitContent located at the specified path, if any. Note that this method should not be used
    ///  to access the content at the root directory. Instead, it should be accessed via the `rootDir` property
    ///  instead.
    func content(at path: Path) -> GitContent? {
        guard let object = directoryStructure.element(at: path) else {
            return nil
        }

        switch object.type {
            // if the git object type is a tree, then the object represents a directory.
            // in that case, we have all the information necessary upfront so we do not
            // need to fetch it.
        case .tree:
            return GitContent(from: object, type: .directory(directory(at: path)))

        // if the blob has a mode of 120000, it is a symlink, otherwise, it is
        // a directory.
        // see: https://stackoverflow.com/a/8347325
        case .blob where object.mode == "120000":
            return symlinkContentFetcher(object, commitSha)

        case .blob:
            return fileContentFetcher(object, commitSha)

        case .commit:
            return submoduleContentFetcher(object, commitSha)
        }
    }

    private func directory(at path: Path) -> GitDirectory {
        let children = directoryStructure.childrenUnder(path: path)

        let dataSource = LazyDataSource {
            .success(children.compactMap { content(at: $0.path) })
        }
        return GitDirectory(contents: dataSource)
    }
}
