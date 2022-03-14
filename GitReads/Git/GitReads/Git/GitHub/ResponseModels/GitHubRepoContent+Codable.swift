//
//  GitHubRepoContent+Codable.swift
//  GitReads

extension GitHubRepoContent: Codable {

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private struct Empty: Encodable {}

    init(from decoder: Decoder) throws {
        do {
            // try to decode as a directory first, which is an array of values
            let container = try decoder.singleValueContainer()
            let value = try container.decode(GitHubDirectoryContent.self)
            self = .directory(value)

        } catch DecodingError.typeMismatch {
            // otherwise, the data is a singular object, we extract the `type` key to
            // figure out which case to decode to.
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let contentType = try container.decodeIfPresent(SingularContentType.self, forKey: .type)

            switch contentType {
            case .some(.file):
                let fileContent = try GitHubFileContent(from: decoder)
                self = .file(fileContent)

            case .some(.submodule):
                let submoduleContent = try GitHubSubmoduleContent(from: decoder)
                self = .submodule(submoduleContent)

            case .some(.symlink):
                let symlinkContent = try GitHubSymlinkContent(from: decoder)
                self = .symlink(symlinkContent)

            case .none:
                self = .unsupported
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .directory(directoryContent):
            var container = encoder.singleValueContainer()
            try container.encode(directoryContent)

        case let .file(fileContent):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SingularContentType.file.rawValue, forKey: .type)
            try fileContent.encode(to: encoder)

        case let .submodule(submoduleContent):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SingularContentType.submodule.rawValue, forKey: .type)
            try submoduleContent.encode(to: encoder)

        case let .symlink(symlinkContent):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SingularContentType.symlink.rawValue, forKey: .type)
            try symlinkContent.encode(to: encoder)

        case .unsupported:
            try Empty().encode(to: encoder)
        }
    }
}
