//
//  SearchBarView.swift
//  GitReads

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var prompt: String = "Search"

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(prompt, text: $searchText)
        }
        .font(.headline)
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    @State static var searchText = ""
    static var previews: some View {
        SearchBarView(searchText: $searchText)
    }
}
