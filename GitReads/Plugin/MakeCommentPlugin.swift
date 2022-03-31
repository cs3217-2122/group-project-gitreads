//
//  MakeCommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//

struct MakeCommentPlugin: Plugin {
    func getLineAction(file: File?, lineNum: Int) -> LineAction? {
        let text = "Make comment on line \(lineNum)"
        return LineAction(text: text, action: { file, lineNum in
            print("Add comment in \(file.name), line \(lineNum)") },
                          takeInput: true) // this will be replaced by the actual comment
    }

    func getTokenAction(file: File?, lineNum: Int, posNum: Int) -> TokenAction? {
        let text = "Make comment on line \(lineNum), pos \(posNum)"
        return TokenAction(text: text, action: { file, lineNum, posNum in
            print("Add comment in \(file.name), line \(lineNum), pos \(posNum)") },
        takeInput: true) // this will be replaced by the actual comment
    }

}
