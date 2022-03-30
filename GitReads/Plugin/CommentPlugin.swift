//
//  CommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 30/3/22.
//

struct CommentPlugin: Plugin {
    func getLineAction(file: File?, lineNum: Int) -> PluginAction {
        // this will be retriveing the comment in future
        let comment = "THIS IS A COMMENT ON LINE \(lineNum)"
        return PluginAction(text: comment, action: { _, _ in })
    }
}
