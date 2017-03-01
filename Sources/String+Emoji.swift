//
//  String+Emoji.swift
//  emoji-swift
//
//  Created by Safx Developer on 2015/04/07.
//  Copyright (c) 2015 Safx Developers. All rights reserved.
//

import Foundation

extension String {

    public static var emojiDictionary = emoji {
        didSet {
            emojiUnescapeRegExp = createEmojiUnescapeRegExp()
            emojiEscapeRegExp = createEmojiEscapeRegExp()
        }
    }

    public fileprivate(set) static var escapePrefixAndSuffix = ":" {
        didSet {
            emojiUnescapeRegExp = createEmojiUnescapeRegExp()
            emojiEscapeRegExp = createEmojiEscapeRegExp()
        }
    }

    fileprivate static var emojiUnescapeRegExp = createEmojiUnescapeRegExp()
    fileprivate static var emojiEscapeRegExp = createEmojiEscapeRegExp()

    public static func setEmojiEscapePrefixAndSuffix(_ newEscapeString: String) {
        escapePrefixAndSuffix = RegexSanitizer.sanitizedString(forString: newEscapeString)
    }

    fileprivate static func createEmojiUnescapeRegExp() -> NSRegularExpression {
        return try! NSRegularExpression(pattern: emojiDictionary.keys.map { "\(escapePrefixAndSuffix)\($0)\(escapePrefixAndSuffix)" } .joined(separator: "|"), options: [])
    }

    fileprivate static func createEmojiEscapeRegExp() -> NSRegularExpression {
        let v = emojiDictionary.values.sorted().reversed()
        return try! NSRegularExpression(pattern: v.joined(separator: "|"), options: [])
    }

    public var emojiUnescapedString: String {
        var s = self as NSString
        let ms = String.emojiUnescapeRegExp.matches(in: self, options: [], range: NSMakeRange(0, s.length))
        ms.reversed().forEach { m in
            let r = m.range
            let p = s.substring(with: r)
            let px = p.substring(with: p.characters.index(after: p.startIndex) ..< p.characters.index(before: p.endIndex))
            if let t = String.emojiDictionary[px] {
                s = s.replacingCharacters(in: r, with: t) as NSString
            }
        }
        return s as String
    }

    public var emojiEscapedString: String {
        var s = self as NSString
        let ms = String.emojiEscapeRegExp.matches(in: self, options: [], range: NSMakeRange(0, s.length))
        let escapePrefixAndSuffix = String.escapePrefixAndSuffix
        ms.reversed().forEach { m in
            let r = m.range
            let p = s.substring(with: r)
            let fs = String.emojiDictionary.lazy.filter { $0.1 == p }
            if let kv = fs.first {
                s = s.replacingCharacters(in: r, with: "\(escapePrefixAndSuffix)\(kv.0)\(escapePrefixAndSuffix)") as NSString
            }
        }
        return s as String
    }

}

fileprivate class RegexSanitizer {

    static fileprivate let regexCharacterRegExp: NSRegularExpression = createRegexCharacterRegExp()

    fileprivate static func createRegexCharacterRegExp() -> NSRegularExpression {
        return try! NSRegularExpression(pattern: "[\\.\\+\\*\\?\\[\\]\\^\\$\\(\\)\\{\\}\\|\\\\\\/]", options: [])
    }

    fileprivate static func sanitizedString(forString original: String) -> String {
        var sanitizedString = original as NSString
        let matches = regexCharacterRegExp.matches(in: original, options: [], range: NSMakeRange(0, sanitizedString.length))
        matches.reversed().forEach { match in
            let stringAtMatch = sanitizedString.substring(with: match.range)
            sanitizedString = sanitizedString.replacingCharacters(in: match.range, with: "\\" + stringAtMatch) as NSString
        }

        return sanitizedString as String
    }
}
