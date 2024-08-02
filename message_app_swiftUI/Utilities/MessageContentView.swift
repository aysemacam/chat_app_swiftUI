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
    var isSelected: Bool
    var toggleSelection: () -> Void
    @State private var isFullScreenPresented = false
    @Binding var isSelectionMode: Bool
    @EnvironmentObject var overlayManager: OverlayManager

    var body: some View {
        HStack {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .padding(.leading)
            }
            
            content
                .background(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isSelectionMode {
                        toggleSelection()
                    } else {
                        overlayManager.showButtonsView = false
                    }
                }
                .onLongPressGesture {
                    isSelectionMode = true
                    toggleSelection()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let text = message.text {
            TextMessageView(text: text, isIncoming: message.isIncoming)
        } else if let media = message.media {
            MediaMessageView(media: media, isIncoming: message.isIncoming)
                .onTapGesture {
                    if isSelectionMode {
                        toggleSelection()
                    } else {
                        if case .audio = media.type {
                        
                        } else {
                            isFullScreenPresented = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $isFullScreenPresented) {
                    FullScreenMediaView(media: media, isPresented: $isFullScreenPresented)
                }
        } else if let contactData = message.contact, let contact = try? CNContactVCardSerialization.contacts(with: contactData).first {
            ContactMessageView(contact: contact)
                .frame(width: 280)
                .frame(maxWidth: .infinity, alignment: message.isIncoming ? .leading : .trailing)
                .padding(.horizontal)
        } else if let location = message.location {
            MapMessageView(location: location, isIncoming: message.isIncoming)
                .onTapGesture {
                    if isSelectionMode {
                        toggleSelection()
                    } else {
                        isFullScreenPresented = true
                    }
                }
                .fullScreenCover(isPresented: $isFullScreenPresented) {
                    FullScreenMapView(location: location, isPresented: $isFullScreenPresented)
                }
                .frame(width: 280)
                .frame(maxWidth: .infinity, alignment: message.isIncoming ? .leading : .trailing)
                .padding(.horizontal)
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
                    .frame(width: 280, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.teaGreen, lineWidth: 8)
                    )
            }
        case .video(let url):
            VideoPlayerView(videoData: url)
                .frame(width: 280, height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .aspectRatio(contentMode: .fill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.teaGreen, lineWidth: 8)
                )
        case .audio(let url):
            AudioPlayerView(audioData: url)
                .frame(width: 280, height: 70)
                .cornerRadius(12)
        }
    }
}
