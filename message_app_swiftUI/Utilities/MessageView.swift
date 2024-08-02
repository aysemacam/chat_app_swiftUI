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
    @State private var selectedMessages: Set<UUID> = []
    @State private var isSelectionMode: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                messagesScrollView
                footerView
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

            if showButtonsView {
                VStack {
                    Spacer()
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(y: -keyboardManager.keyboardHeight - 80)
//                .transition(.move(edge: .bottom))
                .edgesIgnoringSafeArea(.all)
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
        .contentShape(Rectangle()) // To detect taps outside the keyboard
        .onTapGesture {
            self.hideKeyboard()
        }
    }

    private var headerView: some View {
        Group {
            if isSelectionMode {
                SelectionHeaderView(user: user, cancelAction: cancelSelection)
            } else {
                MessageUserView(user: user)
            }
        }
    }

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(user.userChat?.messages ?? []) { message in
                    MessageContentView(
                        message: message,
                        isSelected: selectedMessages.contains(message.id),
                        toggleSelection: { toggleMessageSelection(message) },
                        isSelectionMode: $isSelectionMode
                    )
                    .padding(.vertical, 2)
                    .id(message.id)
                }
            }
            .onAppear {
                print(user.userChat?.messages, "mmmmmm")
                scrollViewProxy = proxy
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: user.userChat?.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private var footerView: some View {
        Group {
            if isSelectionMode {
                SelectionFooterView(
                    selectedCount: selectedMessages.count,
                    deleteAction: deleteSelectedMessages
                )
            } else {
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
    }

    private func toggleMessageSelection(_ message: ChatMessage) {
        if selectedMessages.contains(message.id) {
            selectedMessages.remove(message.id)
        } else {
            selectedMessages.insert(message.id)
        }
        isSelectionMode = !selectedMessages.isEmpty
    }

    private func deleteSelectedMessages() {
        user.userChat?.messages.removeAll { selectedMessages.contains($0.id) }
        selectedMessages.removeAll()
        isSelectionMode = false
        DataManager.shared.saveUserChat(for: user)
    }

    private func cancelSelection() {
        selectedMessages.removeAll()
        isSelectionMode = false
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
        } else if let videoURL = videoURL, let videoData = try? Data(contentsOf: videoURL) {
            let media = ChatMedia(type: .video(videoData))
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
            if let url = audioRecorderManager.stopRecording(), let audioData = try? Data(contentsOf: url) {
                print("Recorded audio file: \(url)")
                let media = ChatMedia(type: .audio(audioData))
                let message = ChatMessage(media: media, isIncoming: false)
                addMessage(message)
            }
        } else {
            audioRecorderManager.startRecording()
        }
    }

    private func startReceivingMessages() {
        // Uncomment and use to simulate receiving messages periodically
        // Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
        //     let incomingMessage = ChatMessage(text: "example received message", isIncoming: true)
        //     addMessage(incomingMessage)
        // }
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
