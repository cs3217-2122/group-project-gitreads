//
//  String+Base64.swift
//  GitReads

import Foundation

extension String {
    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
