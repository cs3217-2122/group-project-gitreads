//
//  TestTokenPlugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 9/4/22.
//
import SwiftUI

struct TestTokenPlugin: Plugin {
    func getLineAction(file: File, lineNum: Int,
                       screenViewModel: ScreenViewModel, codeViewModel: CodeViewModel) -> LineAction? {
        nil
    }

    func getTokenAction(file: File, lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> TokenAction? {
        TokenAction(text: "Test Token Plugin", action: { _, _, _, _ in },
                    view: AnyView(TestView(screenViewModel: screenViewModel, codeViewModel: codeViewModel,
                                           lineNum: lineNum, tokenPos: posNum)))
    }
}

struct TestView: View {
    @State var screenViewModel: ScreenViewModel
    @State var codeViewModel: CodeViewModel
    @State var lineNum: Int
    @State var tokenPos: Int

    var body: some View {
        VStack {
            HStack {
                Text("Testing Token Plugin")
                Spacer()
                Button("Close", action: codeViewModel.resetAction)
            }
            Text("")
            Text("This is \(screenViewModel.repo?.name ?? "Empty repo"), file is \(codeViewModel.file.name)")
            Text("line \(lineNum + 1), position \(tokenPos)")
        }.padding()
    }
}
