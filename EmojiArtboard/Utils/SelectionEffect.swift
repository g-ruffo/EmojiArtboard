//
//  SelectionEffect.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-23.
//

import SwiftUI

struct SelectionEffect: ViewModifier {
    var emoji: Emoji
    var selectedEmojis: Set<Emoji>
    
    func body(content: Content) -> some View {
        content
            .overlay(
                selectedEmojis.contains(emoji) ? RoundedRectangle(cornerRadius: 0).strokeBorder(lineWidth: 3).foregroundColor(.green) : nil
            )
    }
}

extension View {
    func selectionEffect(for emoji: Emoji, in selectedEmojis: Set<Emoji>) -> some View {
        modifier(SelectionEffect(emoji: emoji, selectedEmojis: selectedEmojis))
    }
}
