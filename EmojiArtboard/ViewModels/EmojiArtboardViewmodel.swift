//
//  EmojiArtboardViewmodel.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

class EmojiArtboardViewModel: ReferenceFileDocument {
    
    static var readableContentTypes = [UTType.emojiartboard]
    static var writeableContentTypes = [UTType.emojiartboard]

    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArtboard = try EmojiArtboardModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArtboard.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
        
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
        setBackground(.url(URL(string: "https://blog.hootsuite.com/wp-content/uploads/2020/02/Image-copyright.png")!))
    }
    
    var emojis: [Emoji] { emojiArtboard.emojis}
    var background: EmojiArtboardModel.Background { emojiArtboard.background}
    
    private var backgroundImageDataIfCancellable: AnyCancellable?
    
    
    // MARK: - Intents(s)
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArtboard.background {
        case .url(let url):
            // Fetch the url
            backgroundImageFetchStatus = .fetching
            backgroundImageDataIfCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, urlResponse) in UIImage(data: data)}
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageDataIfCancellable = publisher
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }

//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArtboard.background == EmojiArtboardModel.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
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
