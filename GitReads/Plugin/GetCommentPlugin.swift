//
//  CommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 30/3/22.
//

struct GetCommentPlugin: Plugin {
    func getLineAction(file: File?, lineNum: Int) -> LineAction? {
        // this will be retriveing the comment in future
        let comment = "THIS IS A COMMENT ON LINE \(lineNum)"
        return LineAction(text: comment, action: { _, _ in })
    }

    func getTokenAction(file: File?, lineNum: Int, posNum: Int) -> TokenAction? {
        let comment = "THIS IS A COMMENT ON Line \(lineNum) POS \(posNum)"
        return TokenAction(text: comment, action: { _, _, _ in })
    }
}
