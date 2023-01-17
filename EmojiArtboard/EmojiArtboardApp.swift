//
//  EmojiArtboardApp.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI

@main
struct EmojiArtboardApp: App {
    let viewModel = EmojiArtboardViewModel()
    var body: some Scene {
        WindowGroup {
            EmojiArtboardView(viewModel: viewModel)
        }
    }
}
