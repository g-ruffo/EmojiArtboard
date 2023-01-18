//
//  Background.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-17.
//

import Foundation


extension EmojiArtboardModel {
    enum Background {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
