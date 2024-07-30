//
//  MessageContentView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import MapKit
import Contacts

struct MessageContentView: View {
    let message: ChatMessage
    @State private var isFullScreenPresented = false
    
    var body: some View {
        HStack {
            if let text = message.text {
                TextMessageView(text: text, isIncoming: message.isIncoming)
            } else if let media = message.media {
                MediaMessageView(media: media, isIncoming: message.isIncoming)
                    .onTapGesture {
                        if case .photo = media.type {
                            isFullScreenPresented = true
                        } else if case .video = media.type {
                            isFullScreenPresented = true
                        }
                    }
                    .fullScreenCover(isPresented: $isFullScreenPresented) {
                        FullScreenMediaView(media: media, isPresented: $isFullScreenPresented)
                    }
            } else if let contactData = message.contact, let contact = try? CNContactVCardSerialization.contacts(with: contactData).first {
                ContactMessageView(
                    contact: contact,
                    sendMessageAction: { print("Send Message") },
                    saveContactAction: { print("Save Person") }
                )
                .frame(width: 270)
                .frame(maxWidth: .infinity, alignment: message.isIncoming ? .leading : .trailing)
                .padding(.horizontal)
            } else if let location = message.location {
                MapMessageView(location: location, isIncoming: message.isIncoming)
                    .onTapGesture {
                        isFullScreenPresented = true
                    }
                    .fullScreenCover(isPresented: $isFullScreenPresented) {
                        FullScreenMapView(location: location, isPresented: $isFullScreenPresented)
                    }
                    .frame(width: 270)
                    .frame(maxWidth: .infinity, alignment: message.isIncoming ? .leading : .trailing)
                    .padding(.horizontal)
            }
        }
    }
}

struct FullScreenMapView: View {
    let location: CLLocationCoordinate2D
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )), annotationItems: [AnnotatedItem(coordinate: location)]) { item in
                MapPin(coordinate: item.coordinate)
            }
            .navigationBarTitle("Location", displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                isPresented = false
            })
        }
    }
}

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct TextMessageView: View {
    let text: String
    let isIncoming: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .padding(12)
                .font(.subheadline)
                .foregroundColor(.black)
                .background(isIncoming ? Color.white : Color.teaGreen)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: isIncoming ? .leading : .trailing)
                .padding(.horizontal)
        }
    }
}

struct MediaMessageView: View {
    let media: ChatMedia
    let isIncoming: Bool
    
    var body: some View {
        HStack {
            getMediaView()
                .cornerRadius(12)
                .clipped()
                .frame(maxWidth: .infinity, alignment: isIncoming ? .leading : .trailing)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func getMediaView() -> some View {
        switch media.type {
        case .photo(let imageData):
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 270, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.teaGreen, lineWidth: 8)
                    )
            }
        case .video(let url):
            VideoPlayerView(url: url)
                .frame(width: 270, height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .aspectRatio(contentMode: .fill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.teaGreen, lineWidth: 8)
                )
        case .audio(let url):
            AudioPlayerView(url: url)
                .frame(width: 270, height: 70)
                .cornerRadius(12)
        }
    }
}
