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
    @State var user: User
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
    @State private var scrollViewProxy: ScrollViewProxy?

    var body: some View {
        ZStack {
     
            VStack(spacing: 0) {
                MessageUserView(user: user)
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(user.userChat?.messages ?? []) { message in
                            MessageContentView(message: message)
                                .padding(.vertical, 2)
                                .id(message.id)
                        }
                    }
                    .onAppear {
                        scrollViewProxy = proxy
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: user.userChat?.messages.count) { _ in
                        scrollToBottom(proxy: proxy)
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
                                .background(Color.clear.opacity(0.5))
                            
                                Spacer()
                            }
                            .background(Color.clear)
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
                            addMessage(message)
                        }
                    )
                    .onAppear {
                        loadUserMessages()
                        startReceivingMessages()
                        locationManager.requestLocationPermission()
                    }
                }
            }
            .background(Color.lightGray)
            .padding(.top, 15)
            .sheet(isPresented: $isShowingImagePicker, onDismiss: { showButtonsView = false }) {
                ImagePicker { image, videoURL in
                    handleImagePicked(image: image, videoURL: videoURL)
                }
            }
            .fullScreenCover(isPresented: $isShowingCameraView, onDismiss: { showButtonsView = false }) {
                CustomCameraView(isPresented: $isShowingCameraView, didFinishPicking: handleImagePicked)
            }
            .sheet(isPresented: $isShowingContactPicker, onDismiss: { showButtonsView = false }) {
                ContactPickerView(isPresented: $isShowingContactPicker, selectedContact: $selectedContact)
            }
            .sheet(isPresented: $isShowingMapPicker, onDismiss: { showButtonsView = false }) {
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
                // location found
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
        .navigationBarHidden(true)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = user.userChat?.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func sendMessage() {
        let message = ChatMessage(text: lastMessage, isIncoming: false)
        addMessage(message)
        lastMessage = ""
    }
    
    private func handleImagePicked(image: UIImage?, videoURL: URL?) {
        if let image = image {
            let media = ChatMedia(type: .photo(image.pngData()!))
            let message = ChatMessage(media: media, isIncoming: false)
            addMessage(message)
        } else if let videoURL = videoURL {
            let media = ChatMedia(type: .video(videoURL))
            let message = ChatMessage(media: media, isIncoming: false)
            addMessage(message)
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
                addMessage(message)
            }
        } else {
            audioRecorderManager.startRecording()
        }
    }
    
    private func startReceivingMessages() {
//        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
//            let incomingMessage = ChatMessage(text: "example received message", isIncoming: true)
//            addMessage(incomingMessage)
//        }
    }
    
    private func handleContactSelected(contact: CNContact) {
        let message = ChatMessage(contact: contact, isIncoming: false)
        addMessage(message)
    }
    
    private func sendLocation(location: CLLocationCoordinate2D) {
        let message = ChatMessage(location: location, isIncoming: false)
        addMessage(message)
    }

    private func addMessage(_ message: ChatMessage) {
        if user.userChat == nil {
            user.userChat = UserChat(messages: [])
        }
        user.userChat?.messages.append(message)
        print("Added message: \(message.text ?? "Media Message")")
        DataManager.shared.saveUserChat(for: user)
        if let proxy = scrollViewProxy {
            scrollToBottom(proxy: proxy)
        }
    }

    private func loadUserMessages() {
        if let savedUser = DataManager.shared.fetchUser(byID: user.id) {
            user.userChat = savedUser.userChat
            print("Loaded messages for user: \(user.username)")
        } else {
            print("No messages found for user: \(user.username)")
        }
    }
}
