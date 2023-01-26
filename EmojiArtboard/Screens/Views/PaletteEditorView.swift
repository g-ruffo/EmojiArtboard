//
//  PaletteEditorView.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-25.
//

import SwiftUI

struct PaletteEditorView: View {
    @State private var palette: Palette = PaletteStoreViewModel(named: "Test").palette(at: 2)
    
    var body: some View {
        Form {
            TextField("Name", text: $palette.name)
        }
        .frame(minWidth: 300, minHeight: 350)
    }
}

struct PaletteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditorView()
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/350.0/*@END_MENU_TOKEN@*/))
    }
}
