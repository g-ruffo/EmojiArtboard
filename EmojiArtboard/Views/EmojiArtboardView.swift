//
//  ContentView.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI

struct EmojiArtboardView: View {
    @ObservedObject var viewModel: EmojiArtboardViewModel
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: viewModel.backgroundImage)
                        .position(convertFromEmojiCoordinates((x: 0, y: 0), in: geometry))
                )
                ForEach(viewModel.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
                
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            viewModel.setBackgorund(.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    viewModel.setBackgorund(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    viewModel.addEmoji(String(emoji), at: convertToEmojiCoordinates(location, in: geometry), size: defaultEmojiFontSize)
                }
            }
        }
        return found
    }
    
    private func position(for emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((x: emoji.x, y: emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint (
        x: location.x - center.x,
        y: location.y - center.y
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y))
    }
    
    private func fontSize(for emoji: Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    
    let testEmojis = "😀😃😄😁😆😅😂🤣🥲🥹☺️😊😇🙂🙃😉😌😍"
    
    struct ScrollingEmojisView: View {
        let emojis: String
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .onDrag { NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
        }
    }
}

struct EmojiArtboardView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtboardView(viewModel: EmojiArtboardViewModel())
    }
}
