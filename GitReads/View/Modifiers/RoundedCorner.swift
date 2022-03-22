//
//  RoundedCorner.swift
//  GitReads

import SwiftUI

// Based on:
// https://serialcoder.dev/text-tutorials/swiftui/rounding-specific-corners-in-swiftui-views/
struct RoundedCorner: Shape {
    let corners: UIRectCorner
    let radius: CGFloat

    func path(in rect: CGRect) -> SwiftUI.Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return SwiftUI.Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(corners: corners, radius: radius))
    }
}
