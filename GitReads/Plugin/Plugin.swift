//
//  Plugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

protocol Plugin {
    func getFileAction(file: File,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> [FileAction]

    func getLineAction(file: File, lineNum: Int,
                       screenViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> [LineAction]

    func getTokenAction(file: File, lineNum: Int, posNum: Int,
                        screenViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> [TokenAction]
}
