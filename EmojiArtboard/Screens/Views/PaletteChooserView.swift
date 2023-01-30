//
//  PaletteChooserScreen.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-25.
//

import SwiftUI

struct PaletteChooserView: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font {.system(size: emojiFontSize)}
    
    @EnvironmentObject var viewModel: PaletteStoreViewModel
    
    @SceneStorage("PaletteChooserView.chosenPaletteIndex") private var chosenPaletteIndex = 0
    
    var body: some View {
        HStack {
            paletteControlButton
            body(for: viewModel.palette(at: chosenPaletteIndex))
        }
        .clipped()
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % viewModel.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
            paletteToEdit = viewModel.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            viewModel.insertPalette(named: "New", emojies: "", at: chosenPaletteIndex)
            paletteToEdit = viewModel.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            chosenPaletteIndex = viewModel.removePalette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(viewModel.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = viewModel.palettes.index(matching: palette) {
                        chosenPaletteIndex = index
                    }
                }
            }
        } label : {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
        .popover(item: $paletteToEdit) { palette in
            PaletteEditorView(palette: $viewModel.palettes[palette])
        }
        .sheet(isPresented: $managing) {
            PaletteManagerView()
        }
        
    }
    
    @State private var managing = false
    @State private var paletteToEdit: Palette?
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
    
}

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



struct PaletteChooserScreen_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooserView().environmentObject(PaletteStoreViewModel(named: "1"))
    }
}
