//
//  NavigationOptionView.swift
//  GitReads

import SwiftUI

struct NavigationOptionView: View {
    let searchTerm: String
    let option: FileNavigateOption

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(option.file.path.string)
                .font(.headline)

            StyledText(verbatim: option.preview)
                .style(.highlight(.yellow), ranges: { $0.ranges(of: searchTerm) })
                .style(.bold(), ranges: { $0.ranges(of: searchTerm) })
        }
        .padding()
    }
}

struct NavigationOptionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationOptionView(
            searchTerm: "for",
            option: FileNavigateOption(
            file: File(
                path: Path(string: "/dirA/file1.txt"),
                language: .go,
                declarations: [],
                lines: LazyDataSource(value: [])),
            line: 0,
            preview: "for i := range(5) {"))
    }
}
