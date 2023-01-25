//
//  Emoji.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import Foundation


struct Emoji: Identifiable, Hashable, Codable {
    let text: String
    var x: Int // Offset from the center
    var y: Int // Offset from the center
    var size: Int
    let id: Int

    init(text: String, x: Int, y: Int, size: Int, id: Int) {
        self.text = text
        self.x = x
        self.y = y
        self.size = size
        self.id = id
    }
}
