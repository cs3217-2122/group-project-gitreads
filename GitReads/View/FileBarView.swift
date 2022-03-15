//
//  FileBarView.swift
//  GitReads
//
//  Created by Tan Kang Liang on 14/3/22.
//

import SwiftUI

struct FileBarView: View {
    let file: File
    let onSelectFile: (File) -> Void

    var body: some View {
        Text(file.name)
            .onTapGesture {
                onSelectFile(file)
            }
    }
}

struct FileBarView_Previews: PreviewProvider {
    static var previews: some View {
        FileBarView(file: MOCK_FILE, onSelectFile: { _ in })
    }
}
