//
//  WebApiClient.swift
//  GitReads
//
//  Created by Liu Zimu on 21/3/22.
//

import Foundation

class WebApiClient {

    static func sendParsingRequest(fileString: String,
                                   language: Language) -> Any? {
        let semaphore = DispatchSemaphore(value: 0)

        let url = URL(string: Constants.webParserApiUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: String] = ["string": fileString, "language": language.rawValue]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var result: Any?

        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [Any] {
                    result = responseJson
                    semaphore.signal()
                }
            } else {
                result = nil
            }
        }

        task.resume()
        semaphore.wait()

        return result
    }
}
