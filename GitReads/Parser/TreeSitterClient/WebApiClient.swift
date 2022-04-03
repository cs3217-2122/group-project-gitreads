//
//  WebApiClient.swift
//  GitReads
//
//  Created by Liu Zimu on 21/3/22.
//

import Foundation
import Get

class WebApiClient {

    static let client = APIClient(host: Constants.webParserApiUrl)

    static func getAstJson(apiPath: String,
                           fileString: String,
                           language: Language) async throws -> Any? {

        let req: Request<Data> = .post(apiPath, body: [
            "string": fileString,
            "language": language.rawValue
        ])

        let result = try await client.send(req)
        return try? JSONSerialization.jsonObject(with: result.value, options: [])
    }
}
