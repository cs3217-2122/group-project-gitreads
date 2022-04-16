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
    let setActiveTheme: (String) -> Void

    @Binding var isScrollView: Bool

    let activeTheme: Theme
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
            Text("Font Size")
            HStack {
                Button(action: decreaseSize, label: {
                    Image(systemName: "minus.circle").padding()
                    })
                Text(String(size))
                Button(action: increaseSize, label: {
                    Image(systemName: "plus.circle").padding()
                })
            }
            Divider()
            Text("Theme")
                .padding(.top, 12)
            Menu(activeTheme.name) {
                ForEach(Array(themes.values).sorted { $0.name < $1.name }, id: \.name) { theme in
                    Button(theme.name) {
                        setActiveTheme(theme.name)
                    }
                }
            }
            .padding(.vertical, 12)
            Spacer()
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    @State static var bool = true

    static var previews: some View {
        SettingView(
            closeSideBar: {},
            increaseSize: {},
            decreaseSize: {},
            setActiveTheme: { _ in },
            isScrollView: $bool,
            activeTheme: OneLightTheme(),
            size: 10
        )
    }
}
