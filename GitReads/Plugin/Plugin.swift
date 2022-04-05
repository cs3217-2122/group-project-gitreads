//
//  Plugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

protocol Plugin {
    func getLineAction(repo: Repo?, file: File, lineNum: Int) -> LineAction?
    func getTokenAction(repo: Repo?, file: File, lineNum: Int, posNum: Int) -> TokenAction?
}
