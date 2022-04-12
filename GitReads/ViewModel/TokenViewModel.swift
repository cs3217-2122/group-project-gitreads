//
//  TokenViewModel.swift
//  GitReads

import Combine

class TokenViewModel: ObservableObject {
    let token: Token

    @Published var minified = false

    init(token: Token) {
        self.token = token
    }
}
