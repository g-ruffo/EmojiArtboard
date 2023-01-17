//
//  Extensions.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import Foundation

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex { $0.id == element.id }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
