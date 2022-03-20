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
    @Binding var isScrollView: Bool
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
            Group {
                HStack {
                    Button(action: increaseSize, label: {
                        Image(systemName: "plus.circle").padding()
                    })
                    Text(String(size))
                    Button(action: decreaseSize, label: {
                        Image(systemName: "minus.circle").padding()
                        })
                }
                Toggle(isOn: $isScrollView) {
                    Text("Scroll view")
                }.padding()
            }
            Spacer()
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    @State static var bool = true
    static var previews: some View {
        SettingView(closeSideBar: {}, increaseSize: {}, decreaseSize: {}, isScrollView: $bool, size: 10)
    }
}
