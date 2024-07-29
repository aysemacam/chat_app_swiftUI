//
//  Message.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//
import Foundation
import UIKit
import Contacts
import CoreLocation

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
    let contact: CNContact?
    let location: CLLocationCoordinate2D?
    let isIncoming: Bool
    
    init(text: String, isIncoming: Bool) {
        self.text = text
        self.media = nil
        self.contact = nil
        self.location = nil
        self.isIncoming = isIncoming
    }
    
    init(media: ChatMedia, isIncoming: Bool) {
        self.text = nil
        self.media = media
        self.contact = nil
        self.location = nil
        self.isIncoming = isIncoming
    }
    
    init(contact: CNContact, isIncoming: Bool) {
        self.text = nil
        self.media = nil
        self.contact = contact
        self.location = nil
        self.isIncoming = isIncoming
    }
    
    init(location: CLLocationCoordinate2D, isIncoming: Bool) {
        self.text = nil
        self.media = nil
        self.contact = nil
        self.location = location
        self.isIncoming = isIncoming
    }
}
