//
//  EmojiArtboardViewmodel.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI

class EmojiArtboardViewModel: ObservableObject {
    
    @Published private(set) var emojiArtboard: EmojiArtboardModel {
        didSet {
            if emojiArtboard.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    init() {
        emojiArtboard = EmojiArtboardModel()
    }
    
    var emojis: [Emoji] { emojiArtboard.emojis}
    var background: EmojiArtboardModel.Background { emojiArtboard.background}

    
    
    // MARK: - Intents(s)
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArtboard.background {
        case .url(let url):
            // Fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
            let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArtboard.background == EmojiArtboardModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
            case .imageData(let data): backgroundImage = UIImage(data: data)
            case .blank: break
                
        }
    }
    
    func setBackgorund(_ background: EmojiArtboardModel.Background) {
        emojiArtboard.background = background
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArtboard.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: Emoji, by offset: CGSize) {
        if let index = emojiArtboard.emojis.index(matching: emoji) {
            emojiArtboard.emojis[index].x += Int(offset.width)
            emojiArtboard.emojis[index].y += Int(offset.height)

        }
    }
    
    func scaleEmoji(_ emoji: Emoji, by scale: CGFloat) {
        if let index = emojiArtboard.emojis.index(matching: emoji) {
            emojiArtboard.emojis[index].size = Int((CGFloat(emojiArtboard.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
