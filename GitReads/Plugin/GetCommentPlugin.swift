//
//  CommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 30/3/22.
//
import SwiftUI

struct GetCommentPlugin: Plugin {
    func getLineAction(repo: Repo?, file: File, lineNum: Int) -> LineAction? {
        if let repo = repo, let url = repo.htmlURL?.absoluteString {
            let defaults = UserDefaults.standard
            if let comments = defaults.object(forKey: url) as? [String: [String: String]],
               let fileComment = comments[file.path.string],
               let comment = fileComment[String(lineNum)] {
                return LineAction(text: comment, action: { _, _, _, _ in }, takeInput: false)
            }
        }
        return nil
    }

    func getTokenAction(repo: Repo?, file: File, lineNum: Int, posNum: Int) -> TokenAction? {
        nil
    }
}
