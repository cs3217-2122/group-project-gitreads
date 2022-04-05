//
//  MakeCommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//
import SwiftUI

struct MakeCommentPlugin: Plugin {
    func getLineAction(repo: Repo?, file: File, lineNum: Int) -> LineAction? {
        if let repo = repo, let url = repo.htmlURL?.absoluteString {
            let defaults = UserDefaults.standard
            let text = "Make comment on line \(lineNum + 1)"

            return LineAction(text: text, action: { _, _, lineNum, input in
                if !input.isEmpty {
                    if var repoComment = defaults.object(forKey: url) as? [String: [Int: String]] {
                        if var fileComment = repoComment[file.path.string] {
                            fileComment[lineNum] = input
                        } else {
                            repoComment[file.path.string] = [lineNum: input]
                        }
                        defaults.set(repoComment, forKey: url)
                    } else {
                        let data: [String: [String: String]] = [file.path.string: [String(lineNum): input]]
                        defaults.set(data, forKey: url)
                    }
                }
            }, takeInput: true) // this will be replaced by the actual comment
        }
        return nil
    }

    func getTokenAction(repo: Repo?, file: File, lineNum: Int, posNum: Int) -> TokenAction? {
        nil
    }

}
