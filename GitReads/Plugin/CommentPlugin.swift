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
            let text = "Make comment on line \(lineNum + 1)"

            result.append(LineAction(text: text, action: { _, _, _ in },
                                     view: AnyView(MakeCommentView(lineNum: lineNum, url: url,
                                                                   file: file, codeViewModel: codeViewModel))))
        }
        return result
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> [TokenAction] {
        []
    }

    func getFileAction(file: File, screenViewModel: ScreenViewModel, codeViewModel: CodeViewModel) -> [FileAction] {
        []
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

struct MakeCommentView: View {
    @State var lineNum: Int
    @State var url: String
    @State var file: File
    @State var text = ""
    @State var codeViewModel: CodeViewModel

    var body: some View {
        VStack {
            Text("You are commenting on line \(lineNum + 1)")
            TextField("Enter", text: $text, onCommit: {
                if !text.isEmpty {
                    let defaults = UserDefaults.standard
                    if var repoComment = defaults.object(forKey: url) as? [String: [String: String]] {
                        if var fileComment = repoComment[file.path.string] {
                            fileComment[String(lineNum)] = text
                            repoComment[file.path.string] = fileComment
                        } else {
                            repoComment[file.path.string] = [String(lineNum): text]
                        }
                        defaults.set(repoComment, forKey: url)
                    } else {
                        let data: [String: [String: String]] = [file.path.string: [String(lineNum): text]]
                        defaults.set(data, forKey: url)
                    }
                }
                codeViewModel.resetAction()
            })
        }.padding()
    }
}
