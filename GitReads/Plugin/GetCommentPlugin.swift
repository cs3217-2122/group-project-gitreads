//
//  CommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 30/3/22.
//

struct GetCommentPlugin: Plugin {
    func getLineAction(file: File, lineNum: Int) -> LineAction? {
        // this will be retriveing the comment in future
        if let comments = CommentData.data[file.path], let comment = comments[lineNum] {
            return LineAction(text: comment, action: { _, _, _, _ in }, takeInput: false)
        }
        return LineAction(text: nil, action: { _, _, _, _ in }, takeInput: false)
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int) -> TokenAction? {
        nil
    }
}
