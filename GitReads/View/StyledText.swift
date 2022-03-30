//
//  StyledText.swift
//  GitReads

// File from https://gist.github.com/rnapier/a37cdbf4aabb1e4a6b40436efc2c3114
// swiftlint:disable force_cast no_extension_access_modifier shorthand_operator
import SwiftUI

public struct TextStyle {
    internal let key: NSAttributedString.Key
    internal let apply: (Text) -> Text
    private init(key: NSAttributedString.Key, apply: @escaping (Text) -> Text) {
        self.key = key
        self.apply = apply
    }
}

public extension TextStyle {
    static func foregroundColor(_ color: Color) -> TextStyle {
        TextStyle(key: .init("TextStyleForegroundColor"), apply: { $0.foregroundColor(color) })
    }

    static func bold() -> TextStyle {
        TextStyle(key: .init("TextStyleBold"), apply: { $0.bold() })
    }
}

public struct StyledText {
    private var attributedString: NSAttributedString

    private init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    public func style<S>(_ style: TextStyle,
                         ranges: (String) -> S) -> StyledText
        where S: Sequence, S.Element == Range<String.Index> {
        let newAttributedString = NSMutableAttributedString(attributedString: attributedString)

        for range in ranges(attributedString.string) {
            let nsRange = NSRange(range, in: attributedString.string)
            newAttributedString.addAttribute(style.key, value: style, range: nsRange)
        }

        return StyledText(attributedString: newAttributedString)
    }
}

public extension StyledText {
    // A convenience extension to apply to a single range.
    func style(_ style: TextStyle,
               range: (String) -> Range<String.Index> = { $0.startIndex..<$0.endIndex }) -> StyledText {
        self.style(style, ranges: { [range($0)] })
    }
}

extension StyledText {
    public init(verbatim content: String, styles: [TextStyle] = []) {
        let attributes = styles.reduce(into: [:]) { result, style in
            result[style.key] = style
        }
        attributedString = NSMutableAttributedString(string: content, attributes: attributes)
    }
}

extension StyledText: View {
    public var body: some View { text() }

    public func text() -> Text {
        var text = Text(verbatim: "")
        attributedString
            .enumerateAttributes(in: NSRange(location: 0, length: attributedString.length),
                                 options: []) { attributes, range, _ in
                let string = attributedString.attributedSubstring(from: range).string
                let modifiers = attributes.values.map { $0 as! TextStyle }
                text = text + modifiers.reduce(Text(verbatim: string)) { segment, style in
                    style.apply(segment)
                }
            }
        return text
    }
}

extension TextStyle {
    static func highlight(_ color: Color) -> TextStyle { .foregroundColor(color) }
}

struct StyledText_Previews: PreviewProvider {
    static var previews: some View {
        StyledText(verbatim: "👩‍👩‍👦someText1")
            .style(.highlight(.teal), ranges: { [$0.range(of: "eTex")!, $0.range(of: "1")!] })
            .style(.bold())
    }
}
