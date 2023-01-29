//
//  BackgroundImageFetchStatus.swift
//  EmojiArtboard
//
//  Created by Grayson Ruffo on 2023-01-23.
//

import Foundation

enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
