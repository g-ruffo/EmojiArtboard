//
//  PaletteManagerView.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-25.
//

import SwiftUI

struct PaletteManagerView: View {
    @EnvironmentObject var viewModel: PaletteStoreViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.palettes) { palette in
                    NavigationLink(destination: PaletteEditorView(palette: $viewModel.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                        .gesture(editMode == .active ? tap : nil)
                    }
                }
                .onDelete { indexSet in
                    viewModel.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    viewModel.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .dismissible { presentationMode.wrappedValue.dismiss() }
            .toolbar {
                ToolbarItem { EditButton() }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    var tap: some Gesture {
        TapGesture().onEnded { }
    }
}

struct PaletteManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManagerView()
            .environmentObject(PaletteStoreViewModel(named: "Preview"))
            .preferredColorScheme(.light)
    }
}
