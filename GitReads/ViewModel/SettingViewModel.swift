//
//  SettingViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 18/3/22.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    @Published private(set) var showSideBar = false
    @Published var fontSize = 10

    func toggleSideBar() {
        withAnimation {
            showSideBar.toggle()
        }
    }

    func increaseSize() {
        fontSize += 1
    }

    func decreaseSize() {
        fontSize -= 1
    }
}
