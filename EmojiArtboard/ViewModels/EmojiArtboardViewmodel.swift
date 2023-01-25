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
            autosave()
            if emojiArtboard.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    private struct Autosave {
        static let filename = "Autosaved.emojiArtboard"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArtboard.json()
            print("\(thisFunction) JSON = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode EmojiArtboard as JSON because = \(encodingError.localizedDescription)")

        } catch let error {
            print("\(thisFunction) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArtboard = try? EmojiArtboardModel(url: url) {
            emojiArtboard = autosavedEmojiArtboard
            fetchBackgroundImageDataIfNecessary()
        } else {
            emojiArtboard = EmojiArtboardModel()
            setBackground(.url(URL(string: "https://blog.hootsuite.com/wp-content/uploads/2020/02/Image-copyright.png")!))
        }
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
    
    func setBackground(_ background: EmojiArtboardModel.Background) {
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
    
    func removeEmoji(_ emoji: Emoji) {
        if let index = emojiArtboard.emojis.index(matching: emoji) {
            emojiArtboard.emojis.remove(at: index)
        }
    }
}
