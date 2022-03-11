//
//  LineView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 11/3/22.
//

import SwiftUI

struct LineView: View {
    // will be in viewmodel logic
    let text: String
    var body: some View {
        HStack {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }

    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(text: "TEST test")
    }
}
