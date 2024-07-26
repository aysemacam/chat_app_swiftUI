import SwiftUI
import AVFoundation
import Combine

var globalKeyboardHeight: CGFloat = 0.0

struct MessageView: View {
    @State private var messages: [ChatMessage] = []
    @State private var lastMessage: String = ""
    @State private var isShowingImagePicker = false
    @State private var isShowingCameraView = false
    @State private var isRecordingAudio = false
    @State private var audioRecorder: AVAudioRecorder?
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var showButtonsView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
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
                                PopOverButtons(galleryAction: showGallery)
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
                        .onTapGesture {
                            withAnimation {
                                showButtonsView = false
                            }
                        }
                    }
                    SendMessageView(
                        lastMessage: $lastMessage,
                        sendMessageAction: sendMessage,
                        plusButtonAction: { withAnimation { showButtonsView.toggle() } },
                        cameraButtonAction: { isShowingCameraView = true },
                        micButtonAction: toggleRecording
                    )
                    .background(Color.gray)
                    .onAppear {
                        startReceivingMessages()
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
            .onReceive(keyboardManager.$keyboardHeight) { height in
                globalKeyboardHeight = height
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
    
    private func toggleRecording() {
        if isRecordingAudio {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            let audioFilename = getDocumentsDirectory().appendingPathComponent(UUID().uuidString + ".m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecordingAudio = true
        } catch {
            // Handle error
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecordingAudio = false
        if let url = audioRecorder?.url {
            let media = ChatMedia(type: .audio(url))
            let message = ChatMessage(media: media, isIncoming: false)
            messages.append(message)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func startReceivingMessages() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            let incomingMessage = ChatMessage(text: "example received message", isIncoming: true)
            messages.append(incomingMessage)
        }
    }
}
