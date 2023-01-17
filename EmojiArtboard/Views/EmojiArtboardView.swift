//
//  ContentView.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI

struct EmojiArtboardView: View {
    @ObservedObject var viewModel: EmojiArtboardViewModel
    
    var body: some View {

    }
}

struct EmojiArtboardView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtboardView(viewModel: EmojiArtboardViewModel())
    }
}
