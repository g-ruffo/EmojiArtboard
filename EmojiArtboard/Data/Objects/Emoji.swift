//
//  Emoji.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import Foundation


struct Emoji: Identifiable {
    let text: String
    var x: Int
    var y: Int
    var size: Int
    let id: Int

    fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
        self.text = text
        self.x = x
        self.y = y
        self.size = size
        self.id = id
    }
}
