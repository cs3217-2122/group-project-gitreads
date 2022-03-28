//
//  Plugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 26/3/22.
//

protocol Plugin {
    func modifyFile(file: File) -> File
    func getAdditionFileContent(file: File) -> FileInfo?
}
