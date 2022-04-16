//
//  String+Width.swift
//  GitReads

import UIKit

extension String {
    func width(for font: UIFont?) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self
            .size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
            .width
    }
}
