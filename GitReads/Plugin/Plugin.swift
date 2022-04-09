//
//  Plugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

protocol Plugin {
    func getLineAction(file: File, lineNum: Int,
                       screemViewModel: ScreenViewModel,
                       codeViewModel: CodeViewModel) -> LineAction?
    func getTokenAction(file: File, lineNum: Int, posNum: Int,
                        screemViewModel: ScreenViewModel,
                        codeViewModel: CodeViewModel) -> TokenAction?
}
