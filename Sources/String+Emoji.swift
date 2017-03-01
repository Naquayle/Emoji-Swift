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

    public static var escapePrefixAndSuffix = ":" {
        didSet {
            emojiUnescapeRegExp = createEmojiUnescapeRegExp()
            emojiEscapeRegExp = createEmojiEscapeRegExp()
        }
    }

    fileprivate static var emojiUnescapeRegExp = createEmojiUnescapeRegExp()
    fileprivate static var emojiEscapeRegExp = createEmojiEscapeRegExp()

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
