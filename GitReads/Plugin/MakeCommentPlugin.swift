//
//  MakeCommentPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 31/3/22.
//
import SwiftUI

struct MakeCommentPlugin: Plugin {
    func getLineAction(file: File, lineNum: Int,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> LineAction? {
        if let repo = screenViewModel.repo, let url = repo.htmlURL?.absoluteString {
            let text = "Make comment on line \(lineNum + 1)"

            return LineAction(text: text, action: { _, _, _ in },
                              view: AnyView(MakeCommentView(lineNum: lineNum, url: url,
                                                            file: file, codeViewModel: codeViewModel)))
        }
        return nil
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> TokenAction? {
        nil
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
            HStack {
                Text("You are commenting on line \(lineNum + 1)")
                Spacer()
                Button("Cancel", action: { codeViewModel.resetAction() })
            }
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
