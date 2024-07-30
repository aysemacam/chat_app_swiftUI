//
//  MessageView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import SwiftUI
import Contacts
import ContactsUI
import AVFoundation
import Combine
import CoreLocation

struct MessageView: View {
    @State private var messages: [ChatMessage] = []
    @State private var lastMessage: String = ""
    @State private var isShowingImagePicker = false
    @State private var isShowingCameraView = false
    @State private var isRecordingAudio = false
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var showButtonsView = false
    @State private var isShowingContactPicker = false
    @State private var selectedContact: CNContact?
    @StateObject private var locationManager = LocationManager()
    @State private var isShowingMapPicker = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @StateObject private var audioRecorderManager = AudioRecorderManager()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                MessageUserView()
                ScrollView {
                    ForEach(messages) { message in
                        MessageContentView(message: message)
                            .padding(.vertical, 2)
                    }
                }
                VStack {
                    if showButtonsView {
                        VStack {
                            HStack {
                                PopOverButtons(
                                    galleryAction: showGallery,
                                    contactAction: showContactPicker,
                                    sendLocationAction: { _ in
                                        isShowingMapPicker = true
                                    }
                                )
                                .frame(width: 110, height: 120)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(10)
                                .shadow(radius: 1)
                                Spacer()
                            }
                            .padding(.leading)
                        }
                        .background(Color.clear)
                        .edgesIgnoringSafeArea(.all)
                    }
                    SendMessageView(
                        lastMessage: $lastMessage,
                        sendMessageAction: sendMessage,
                        plusButtonAction: { withAnimation { showButtonsView.toggle() } },
                        cameraButtonAction: { isShowingCameraView = true },
                        micButtonAction: { message in
                            messages.append(message)
                        }
                    )
                    .background(Color.gray)
                    .onAppear {
                        startReceivingMessages()
                        locationManager.requestLocationPermission()
                    }
                }
            }
            .background(Color.lightGray)
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker { image, videoURL in
                    handleImagePicked(image: image, videoURL: videoURL)
                }
            }
            .fullScreenCover(isPresented: $isShowingCameraView) {
                CustomCameraView(isPresented: $isShowingCameraView, didFinishPicking: handleImagePicked)
            }
            .sheet(isPresented: $isShowingContactPicker) {
                ContactPickerView(isPresented: $isShowingContactPicker, selectedContact: $selectedContact)
            }
            .sheet(isPresented: $isShowingMapPicker) {
                MapPickerView(isPresented: $isShowingMapPicker, selectedLocation: $selectedLocation)
            }
            .onChange(of: selectedContact) { contact in
                if let contact = contact {
                    handleContactSelected(contact: contact)
                }
            }
        }
        .onReceive(locationManager.$userLocation) { newLocation in
            if let newLocation = newLocation {
            } else {
                print("Cannot find location info.")
            }
        }
        .onReceive(locationManager.$locationStatus) { status in
            if status == .denied || status == .restricted {
                print("Location Not accepted.")
            } else if status == .notDetermined {
                locationManager.requestLocationPermission()
            } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        }
        .onReceive(locationManager.$locationError) { error in
            if let error = error {
                print("Location Error: \(error.localizedDescription)")
            }
        }
        .onChange(of: selectedLocation) { location in
            if let location = location {
                sendLocation(location: location)
            }
        }
    }
    
    private func sendMessage() {
        let message = ChatMessage(text: lastMessage, isIncoming: false)
        messages.append(message)
        lastMessage = ""
    }
    
    private func handleImagePicked(image: UIImage?, videoURL: URL?) {
        if let image = image {
            let media = ChatMedia(type: .photo(image))
            let message = ChatMessage(media: media, isIncoming: false)
            messages.append(message)
        } else if let videoURL = videoURL {
            let media = ChatMedia(type: .video(videoURL))
            let message = ChatMessage(media: media, isIncoming: false)
            messages.append(message)
        }
    }

    private func showGallery() {
        isShowingImagePicker = true
    }
    
    private func showContactPicker() {
        isShowingContactPicker = true
    }
    
    private func toggleRecording() {
        if audioRecorderManager.isRecording {
            if let url = audioRecorderManager.stopRecording() {
                print("Recorded audio file: \(url)")
                let media = ChatMedia(type: .audio(url))
                let message = ChatMessage(media: media, isIncoming: false)
                messages.append(message)
            }
        } else {
            audioRecorderManager.startRecording()
        }
    }
    
    private func startReceivingMessages() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            let incomingMessage = ChatMessage(text: "example received message", isIncoming: true)
            messages.append(incomingMessage)
        }
    }
    
    private func handleContactSelected(contact: CNContact) {
        let message = ChatMessage(contact: contact, isIncoming: false)
        messages.append(message)
    }
    
    private func sendLocation(location: CLLocationCoordinate2D) {
        let message = ChatMessage(location: location, isIncoming: false)
        messages.append(message)
    }
}
#Preview {
    MessageView()
}
