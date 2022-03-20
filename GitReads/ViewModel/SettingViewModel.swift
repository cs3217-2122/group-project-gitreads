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
    @Published var fontSize = 25
    @Published var isScrollView = true
    let minSize = 10
    let maxSize = 30

    func toggleSideBar() {
        withAnimation {
            showSideBar.toggle()
        }
    }

    func hideSideBar() {
        withAnimation {
            showSideBar = false
        }
    }

    func increaseSize() {
        if fontSize > minSize {
            fontSize += 1
        }
    }

    func decreaseSize() {
        if fontSize < maxSize {
            fontSize -= 1
        }
    }

    func toggleViewOption() {
        withAnimation {
            isScrollView.toggle()
        }
    }
}
