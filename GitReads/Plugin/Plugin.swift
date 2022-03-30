//
//  Plugin.swift
//  GitReads
//
//  Created by Zhou Jiahao on 28/3/22.
//

// ONLY LINE FOR NOW
protocol Plugin {
    func getLineAction(file: File?, lineNum: Int) -> PluginAction
}
