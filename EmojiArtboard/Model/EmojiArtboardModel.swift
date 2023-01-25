//
//  EmojiArtboard.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import Foundation

struct EmojiArtboardModel: Codable {
    var background = Background.blank
    var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    init() { }
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
    
}
