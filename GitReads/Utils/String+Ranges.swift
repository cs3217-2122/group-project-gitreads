//
//  String+Ranges.swift
//  GitReads

import Foundation

// https://stackoverflow.com/questions/36865443/get-all-ranges-of-a-substring-in-a-string-in-swift
extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(
            of: substring,
            options: options,
            range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}
