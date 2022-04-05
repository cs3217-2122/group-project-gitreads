//
//  ParseOutput.swift
//  GitReads

struct ParseOutput: Codable {
    let fileContents: String
    let lines: [Line]
}
