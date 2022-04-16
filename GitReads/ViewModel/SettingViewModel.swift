//
//  SettingViewModel.swift
//  GitReads
//
//  Created by Zhou Jiahao on 18/3/22.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    static let fontSizeKey = "fontSizeSetting"
    static let isScrollViewKey = "isScrollViewSetting"
    static let themeKey = "themeSetting"

    @Published private(set) var showSideBar = false
    @Published var fontSize: Int {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: SettingViewModel.fontSizeKey)
        }
    }

    @Published var isScrollView: Bool {
        didSet {
            UserDefaults.standard.set(isScrollView, forKey: SettingViewModel.isScrollViewKey)
        }
    }

    @Published private(set) var activeTheme: Theme

    let minSize = 10
    let maxSize = 30

    init() {
        let fontSize = UserDefaults.standard.integer(forKey: SettingViewModel.fontSizeKey)
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
        let themeName = UserDefaults.standard.string(forKey: SettingViewModel.themeKey)
        if let themeName = themeName {
            self.activeTheme = themes[themeName] ?? OneLightTheme()
        } else {
            self.activeTheme = OneLightTheme()
        }

        if self.isKeyPresentInUserDefaults(key: SettingViewModel.isScrollViewKey) {
            self.isScrollView = UserDefaults.standard.bool(forKey: SettingViewModel.isScrollViewKey)
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

    func setTheme(name: String) {
        if let theme = themes[name] {
            activeTheme = theme
            UserDefaults.standard.set(name, forKey: SettingViewModel.themeKey)
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
