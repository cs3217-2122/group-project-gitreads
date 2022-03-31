//
//  MakeCommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct MakeCommentPlugin: Plugin {
    func getLineAction(file: File?, lineNum: Int) -> LineAction? {
        nil
    }

    func getTokenAction(file: File?, lineNum: Int, posNum: Int) -> TokenAction? {
        nil
    }

}
