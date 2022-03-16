//
//  GitHubErrorResponse.swift
//  GitReads

struct GitHubErrorResponse: Codable {
    let message: String
    let errors: [ErrorField]?
    let documentationURL: String

    private enum CodingKeys: String, CodingKey {
        case message
        case errors
        case documentationURL = "documentation_url"
    }

    struct ErrorField: Codable {
        let resource: String
        let field: String
        let code: ErrorCode
    }

    enum ErrorCode: String, Codable {
        case tooLarge = "too_large"
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let stringRepresentation = try container.decode(String.self)

            // if the string rep is not of the handled codes, default to .unknown
            if let code = ErrorCode(rawValue: stringRepresentation) {
                self = code
            } else {
                self = .unknown
            }
        }
    }
}
