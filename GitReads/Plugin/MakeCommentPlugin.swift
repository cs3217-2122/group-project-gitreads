//
//  MakeCommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct MakeCommentPlugin: Plugin {
    func getLineAction(file: File?, lineNum: Int) -> LineAction? {
        let text = "Make comment on line \(lineNum)"
        return LineAction(text: text, action: { _, lineNum, input in
            CommentData.data[lineNum] = input },
                          takeInput: true) // this will be replaced by the actual comment
    }

    func getTokenAction(file: File?, lineNum: Int, posNum: Int) -> TokenAction? {
        nil
    }

}
