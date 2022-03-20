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
        for line in file.lines {
            // will add more logic in future
            result.append(line)
        }
        return result
    }
}
