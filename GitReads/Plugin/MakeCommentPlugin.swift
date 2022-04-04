//
//  MakeCommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct MakeCommentPlugin: Plugin {
    func getLineAction(file: File, lineNum: Int) -> LineAction? {
        let text = "Make comment on line \(lineNum + 1)"
        return LineAction(text: text, action: { _, _, lineNum, input in
            if !input.isEmpty {
                if var comments = CommentData.data[file.path] {
                    comments[lineNum] = input
                } else {
                    CommentData.data[file.path] = [lineNum: input]
                }
            }}, takeInput: true) // this will be replaced by the actual comment
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int) -> TokenAction? {
        nil
    }

}
