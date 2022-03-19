//
//  SettingView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 19/3/22.
//

import SwiftUI

struct SettingView: View {
    let closeSideBar: () -> Void
    let increaseSize: () -> Void
    let decreaseSize: () -> Void
    var size: Int

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .padding()
                    .foregroundColor(.accentColor)
                    .onTapGesture(perform: closeSideBar)
            }
            VStack {
                Button(action: increaseSize, label: {
                    Image(systemName: "plus.circle").padding()
                    })
                Text(String(size))
                Button(action: decreaseSize, label: {
                    Image(systemName: "minus.circle").padding()
                    })
            }
            Spacer()
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(closeSideBar: {}, increaseSize: {}, decreaseSize: {}, size: 10)
    }
}
