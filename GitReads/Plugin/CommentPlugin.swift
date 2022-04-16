//
//  CommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 30/3/22.
//
import SwiftUI

struct CommentPlugin: Plugin {
    func getLineAction(file: File, lineNum: Int,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> [LineAction] {
        var result: [LineAction] = []
        if let repo = screenViewModel.repo, let url = repo.htmlURL?.absoluteString {
            let defaults = UserDefaults.standard
            if let comments = defaults.object(forKey: url) as? [String: [String: String]],
               let fileComment = comments[file.path.string],
               let comment = fileComment[String(lineNum)] {
                var lineAction = LineAction(text: comment, action: { _, _, _ in },
                                            view: AnyView(GetCommentView(comment: comment,
                                                                         lineNum: lineNum,
                                                                         codeViewModel: codeViewModel)))
                lineAction.isHighlighted = true
                result.append(lineAction)
            }
        }
        if let repo = screenViewModel.repo, let url = repo.htmlURL?.absoluteString {
            let text = "Make comment on line \(lineNum + 1)"

            result.append(LineAction(text: text, action: { _, _, _ in },
                               view: AnyView(MakeCommentView(lineNum: lineNum, url: url,
                                                            file: file, codeViewModel: codeViewModel))))
        }
        return result
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> TokenAction? {
        nil
    }
}

struct GetCommentView: View {
    @State var comment: String
    @State var lineNum: Int
    @State var codeViewModel: CodeViewModel

    var body: some View {
        VStack {
            Text("Viewing comment on line \(lineNum + 1)")
            Text("")
            Text(comment)
        }.padding()
    }
}
