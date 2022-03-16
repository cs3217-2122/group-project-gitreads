//
//  GitObject.swift
//  GitReads

enum GitObjectType: String, Codable {
    case tree
    case blob
    case commit
}

struct GitObject {
    let type: GitObjectType

    let path: Path
    let mode: String
    let sha: String
    let sizeInBytes: Int?
}

extension GitContent {
    init(from object: GitObject, type: GitContentType) {
        self.init(
            type: type,
            name: object.path.lastPathComponent ?? "",
            path: object.path,
            sha: object.sha,
            sizeInBytes: object.sizeInBytes ?? 0
        )
    }
}
