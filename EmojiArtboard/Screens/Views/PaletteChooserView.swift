//
//  PaletteChooserScreen.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-25.
//

import SwiftUI

struct PaletteChooserView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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


struct PaletteChooserScreen_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooserScreen()
    }
}
