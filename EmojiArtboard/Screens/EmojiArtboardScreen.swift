//
//  ContentView.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import SwiftUI

struct EmojiArtboardScreen: View {
    @ObservedObject var viewModel: EmojiArtboardViewModel
    
    @Environment(\.undoManager) var undoManager
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooserView(emojiFontSize: defaultEmojiFontSize)
        }
    }
    
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: viewModel.backgroundImage)
                        .scaleEffect(selectedEmojis.isEmpty ? zoomScale : steadyStateZoomScale)
                        .position(convertFromEmojiCoordinates((x: 0, y: 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                
                if viewModel.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.orange))
                } else {
                    ForEach(viewModel.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .selectionEffect(for: emoji, in: selectedEmojis)
                            .scaleEffect(getZoomScaleForEmoji(emoji))
                            .position(position(for: emoji, in: geometry))
                            .gesture(selectionGesture(on: emoji)
                                .simultaneously(with: longPressToDelete(on: emoji)
                                    .simultaneously(with: selectedEmojis.contains(emoji) ? panEmojiGesture(on: emoji) : nil)))
                        
                        
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(zoomGesture()
                .simultaneously(with: gestureEmojiPanOffset == CGSize.zero ? panGesture() : nil))
            .alert("Delete", isPresented: $showDeleteAlert, presenting: deleteEmoji) { deleteEmoji in
                deleteEmojiOnDemand(for: deleteEmoji)
            }
            .alert(item: $alertToShow) { alertToShow in
                // Return Alert
                alertToShow.alert()
            }
            .onChange(of: viewModel.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchAlert(url)
                default: break
                }
            }
            .onReceive(viewModel.$backgroundImage) { image in
                if autozoom {
                    zoomToFit(image, in: geometry.size)

                }
            }
            .toolbar {
                UndoButton(
                    undo: undoManager?.optionalUndoMenuItemTitle,
                    redo: undoManager?.optionalUndoMenuItemTitle
                )
            }
        }
    }
    
    @State private var alertToShow: IdentifiableAlert?
    
    @State private var autozoom = false
    
    private func showBackgroundImageFetchAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "Fetch failed: " + url.absoluteString, alert: {
            Alert(title: Text("Background Image Fetch"),
            message: Text("Couldn't load image from \(url)."),
                  dismissButton: .default(Text("OK"))
                  )
        })
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            autozoom = true
            viewModel.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    autozoom = true
                    viewModel.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    viewModel.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale,
                        undoManager: undoManager
                    )
                }
            }
        }
        return found
    }
    
    private func position(for emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        if selectedEmojis.contains(emoji) {
            return convertFromEmojiCoordinates((emoji.x + Int(gestureEmojiPanOffset.width), emoji.y + Int(gestureEmojiPanOffset.height)), in: geometry)
        } else {
            return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
        }    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint (
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    private func fontSize(for emoji: Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    @SceneStorage("EmojiArtboardScreen.steadyStateZoomScale") private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    @GestureState private var gestureEmojiPanOffset: CGSize = CGSize.zero
    
    @SceneStorage("EmojiArtboardScreen.steadyStatePanOffset") private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func getZoomScaleForEmoji(_ emoji: Emoji) -> CGFloat {
        selectedEmojis.isEmpty ? zoomScale : selectedEmojis.contains(emoji) ? zoomScale : steadyStateZoomScale
    }
    
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGesture in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGesture.translation / zoomScale)
            }
    }
    
    private func panEmojiGesture(on emoji: Emoji) -> some Gesture {
        DragGesture()
            .updating($gestureEmojiPanOffset) { latestDragGestureValue, gestureEmojiPanOffset, _ in
                gestureEmojiPanOffset = latestDragGestureValue.distance / zoomScale
            }
            .onEnded { finalDragGestureValue in
                for emoji in selectedEmojis {
                    viewModel.moveEmoji(emoji, by: finalDragGestureValue.distance / zoomScale, undoManager: undoManager)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
                
            }
            .onEnded { gestureScaleAtEnd in
                if selectedEmojis.isEmpty {
                    steadyStateZoomScale *= gestureScaleAtEnd
                } else {
                    for emoji in selectedEmojis {
                        viewModel.scaleEmoji(emoji, by: gestureScaleAtEnd, undoManager: undoManager)
                    }
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(viewModel.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Selecting and Unselecting Emojis
    
    @State private var selectedEmojisId = Set<Int>()
    
    private var selectedEmojis: Set<Emoji> {
        var selectedEmojis = Set<Emoji>()
        for id in selectedEmojisId {
            selectedEmojis.insert(viewModel.emojis.first(where: {$0.id == id})!)
        }
        return selectedEmojis
    }
    
    private func selectionGesture(on emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                withAnimation {
                    selectedEmojisId.toggleMembership(of: emoji.id)
                }
            }
    }
    
    // MARK: - Deleting Emojis
    
    @State private var showDeleteAlert = false
    @State private var deleteEmoji: Emoji?
    
    private func longPressToDelete(on emoji: Emoji) -> some Gesture {
        LongPressGesture(minimumDuration: 1.2)
            .onEnded { LongPressStateAtEnd in
                if LongPressStateAtEnd {
                    deleteEmoji = emoji
                    showDeleteAlert.toggle()
                } else {
                    deleteEmoji = nil
                }
            }
    }
    
    private func deleteEmojiOnDemand(for emoji: Emoji) -> some View {
        Button(role: .destructive) {
            if selectedEmojis.contains(emoji) { selectedEmojisId.remove(emoji.id) }
            viewModel.removeEmoji(emoji, undoManager: undoManager)
        } label: { Text("Yes") }
    }
    
    private func tapToUnselectAllEmojis() -> some Gesture {
        TapGesture()
            .onEnded {
                withAnimation {
                    selectedEmojisId = []
                }
            }
    }
}
    

struct EmojiArtboardView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtboardScreen(viewModel: EmojiArtboardViewModel())
    }
}
