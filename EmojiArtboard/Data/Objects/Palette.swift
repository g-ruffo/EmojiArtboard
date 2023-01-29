//
//  Palette.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-24.
//

import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id: Int
    
    init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}
