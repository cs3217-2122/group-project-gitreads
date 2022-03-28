//
//  PluginManager.swift
//  GitReads
//
//  Created by Zhou Jiahao on 26/3/22.
//

class PluginManager {
    private var plugins: [Plugin]
    var displayOption: DisplayOption

    init(plugins: [Plugin], displayOption: DisplayOption) {
        self.plugins = plugins
        self.displayOption = displayOption
    }

    func getModifiedFile(file: File) -> File {
        var result = file
        for plugin in plugins {
            result = plugin.modifyFile(file: result)
        }
        return result
    }

    func combineFileInfo(file: File) -> FileInfo? {
        var result: FileInfo?
        for plugin in plugins {
            if let current = result, let next = plugin.getAdditionFileContent(file: file) {
                result = current.combineFileInfo(other: next)
            } else if result != nil {
                result = plugin.getAdditionFileContent(file: file)
            }
        }
        return result
    }
}
