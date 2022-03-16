//
//  FileParser.swift
//  GitReads
//
//  Created by Tan Kang Liang on 16/3/22.
//

protocol FileParser {
    func parse(fileString: String, name: String) -> File?
}
