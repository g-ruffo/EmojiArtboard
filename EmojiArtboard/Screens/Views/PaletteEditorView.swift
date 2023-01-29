//
//  PaletteEditorView.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-25.
//

import SwiftUI

struct PaletteEditorView: View {
    @Binding var palette: Palette
    
    var body: some View {
        Form {
            nameSection
            addEmojisSection
            removeEmojisSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)
        }
    }
    
    @State private var emojisToAdd = ""

var addEmojisSection: some View {
    Section(header: Text("Add Emojies")) {
        TextField("", text: $emojisToAdd)
            .onChange(of: emojisToAdd) { emojis in
                addEmojis(emojis)
            }
    }
}
    
    var removeEmojisSection: some View {
        Section(header: Text("Remove Emojies")) {
            let emojis = palette.emojis.map { String($0)}
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    func addEmojis(_ emojis: String) {
        palette.emojis = (emojis + palette.emojis)
            .filter { $0.isEmoji}
    }
}

struct PaletteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditorView(palette: .constant(PaletteStoreViewModel(named: "Preview").palette(at: 4)))
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/350.0/*@END_MENU_TOKEN@*/))
    }
}
