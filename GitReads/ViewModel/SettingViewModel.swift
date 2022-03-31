//
//  SettingViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 18/3/22.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    private let fontSizeKey = "fontSizeSetting"
    private let isScrollViewKey = "isScrollViewSetting"

    @Published private(set) var showSideBar = false
    @Published var fontSize: Int {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: fontSizeKey)
        }
    }

    @Published var isScrollView: Bool {
        didSet {
            UserDefaults.standard.set(isScrollView, forKey: isScrollViewKey)
        }
    }

    let minSize = 10
    let maxSize = 30

    init() {
        let fontSize = UserDefaults.standard.integer(forKey: fontSizeKey)
        if fontSize != 0 {
            self.fontSize = fontSize
        } else {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.fontSize = 18
            case .pad:
                self.fontSize = 25
            default:
                self.fontSize = 25
            }
        }

        self.isScrollView = true
        if self.isKeyPresentInUserDefaults(key: isScrollViewKey) {
            self.isScrollView = UserDefaults.standard.bool(forKey: isScrollViewKey)
        }
    }

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
        if fontSize < maxSize {
            fontSize += 1
        }
    }

    func decreaseSize() {
        if fontSize > minSize {
            fontSize -= 1
        }
    }

    func toggleViewOption() {
        withAnimation {
            isScrollView.toggle()
        }
    }

    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        UserDefaults.standard.object(forKey: key) != nil
    }
}
