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
    Color.yellow
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
