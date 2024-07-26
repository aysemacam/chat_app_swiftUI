//
//  Message.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//
import Foundation
import UIKit

enum MediaType {
    case photo(UIImage)
    case video(URL)
    case audio(URL)
}

struct ChatMedia: Identifiable {
    let id = UUID()
    let type: MediaType
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String?
    let media: ChatMedia?
    let isIncoming: Bool
    
    init(text: String, isIncoming: Bool) {
        self.text = text
        self.media = nil
        self.isIncoming = isIncoming
    }
    
    init(media: ChatMedia, isIncoming: Bool) {
        self.text = nil
        self.media = media
        self.isIncoming = isIncoming
    }
}
