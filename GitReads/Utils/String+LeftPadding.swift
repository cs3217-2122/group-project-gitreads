//
//  String+LeftPadding.swift
//  GitReads

import Foundation

// Taken from StackOverflow: https://stackoverflow.com/a/69859859
extension String {
    func leftPadding(toLength: Int, withPad: String) -> String {
        String(String(reversed()).padding(toLength: toLength, withPad: withPad, startingAt: 0).reversed())
    }
}
