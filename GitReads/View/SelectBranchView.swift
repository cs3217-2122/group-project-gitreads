//
//  SelectBranchView.swift
//  GitReads

import SwiftUI
import Fuse

struct SelectBranchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let fuse = Fuse()

    @State private var searchText = ""

    let defaultBranch: String
    let branches: [String]

    let onBranchSelected: (String) -> Void

    var filteredBranches: [String] {
        if searchText.isEmpty {
            return branches
        }

        let results = fuse.search(searchText, in: branches)
        return results.map { branches[$0.index] }
    }

    func branchItem(_ branch: String) -> some View {
        Button {
            onBranchSelected(branch)
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Text(branch)
                if branch == defaultBranch {
                    Text("default")
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundColor(.black)
                        .background(Capsule().fill(Color(.systemGray5)))
                }
            }
        }
    }

    var body: some View {
        List {
            ForEach(filteredBranches, id: \.self) { branch in
                branchItem(branch)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Choose a branch")
    }
}
