//
//  Color+Init.swift
//  GitReads

import SwiftUI

extension Color {
    // Taken from StackOverflow: https://stackoverflow.com/a/62632214
    init(hue: Double, saturation: Double, lightness: Double, opacity: Double = 1) {
        precondition(0...1 ~= hue &&
                     0...1 ~= saturation &&
                     0...1 ~= lightness &&
                     0...1 ~= opacity, "input range is out of range 0...1")

        // From HSL TO HSB ---------
        var newSaturation: Double = 0.0

        let brightness = lightness + saturation * min(lightness, 1 - lightness)

        if brightness == 0 { newSaturation = 0.0 } else {
            newSaturation = 2 * (1 - lightness / brightness)
        }
        // ---------

        self.init(hue: hue, saturation: newSaturation, brightness: brightness, opacity: opacity)
    }

    // Taken from StackOverflow: https://stackoverflow.com/a/56894458
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
