//
//  String+Width.swift
//  GitReads

import UIKit

extension String {
    func size(for font: UIFont?) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self
            .size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
    }

    func width(for font: UIFont?) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self
            .size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
            .width
    }

    func height(for font: UIFont?) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self
            .size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
            .height
    }
}
