//
//  EmojiArtboardApp.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI

@main
struct EmojiArtboardApp: App {
    @StateObject var emojiArtboardViewModel = EmojiArtboardViewModel()
    @StateObject var paletteStoreViewModel = PaletteStoreViewModel(named: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtboardViewModel() }) { config in
            EmojiArtboardScreen(viewModel: config.document)
                .environmentObject(paletteStoreViewModel)
        }
    }
}
