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

enum MediaType: Codable {
    case photo(Data)
    case video(URL)
    case audio(URL)
    
    enum CodingKeys: String, CodingKey {
        case type, data
    }
    
    enum MediaTypeCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "photo":
            let data = try container.decode(Data.self, forKey: .data)
            self = .photo(data)
        case "video":
            let url = try container.decode(URL.self, forKey: .data)
            self = .video(url)
        case "audio":
            let url = try container.decode(URL.self, forKey: .data)
            self = .audio(url)
        default:
            throw MediaTypeCodingError.decoding("Unknown type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .photo(let data):
            try container.encode("photo", forKey: .type)
            try container.encode(data, forKey: .data)
        case .video(let url):
            try container.encode("video", forKey: .type)
            try container.encode(url, forKey: .data)
        case .audio(let url):
            try container.encode("audio", forKey: .type)
            try container.encode(url, forKey: .data)
        }
    }
}

struct ChatMedia: Identifiable, Codable {
    let id = UUID()
    let type: MediaType
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String?
    let media: ChatMedia?
    let contact: Data?
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
        self.contact = try? CNContactVCardSerialization.data(with: [contact])
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

struct User: Identifiable, Codable {
    let id: UUID
    let username: String
    let userPhoto: Data
    var userChat: UserChat?

    init(username: String, userPhoto: Data, userChat: UserChat? = nil) {
        self.id = UUID()
        self.username = username
        self.userPhoto = userPhoto
        self.userChat = userChat
    }
}

struct UserChat: Identifiable, Codable {
    let id = UUID()
    var messages: [ChatMessage]
}

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
