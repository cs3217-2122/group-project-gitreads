//
//  GitRef.swift
//  GitReads

enum GitRef {
    case branch(String)
    case tag(String)

    var name: String {
        switch self {
        case let .branch(str):
            return str
        case let .tag(str):
            return str
        }
    }
}
