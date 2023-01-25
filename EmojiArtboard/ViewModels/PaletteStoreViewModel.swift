//
//  PaletteStoreViewModel.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-24.
//

import SwiftUI

class PaletteStoreViewModel: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]()
    
    init(named name: String) {
        self.name = name
    }
    
    // MARK: - Intent
    
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1 && palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojies: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojies ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
