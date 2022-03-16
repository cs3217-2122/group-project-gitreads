//
//  CodeViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import Foundation

class CodeViewModel {
    func getLines(file: File) -> [Line] {
        var result: [Line] = []
        for (index, line) in file.lines.enumerated() {
            // will add more logic in future
            result.append(line)
        }
        return result
    }
}
