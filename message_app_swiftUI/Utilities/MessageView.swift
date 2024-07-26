import SwiftUI
import AVFoundation
import Combine

var globalKeyboardHeight: CGFloat = 0.0

struct MessageView: View {
    @State private var messages: [ChatMessage] = []
    @State private var lastMessage: String = ""
    @State private var isShowingImagePicker = false
    @State private var isRecordingAudio = false
    @State private var audioRecorder: AVAudioRecorder?
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var showButtonsView = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(messages) { message in
                    MessageContentView(message: message)
                        .padding(.vertical, 2)
                }
            }
            
            VStack {
                if showButtonsView {
                    HStack {
                        VStack {
                            ButtonsView()
                                .frame(width: 110, height: 120, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                                .transition(.move(edge: .bottom))
                                .padding(.leading)
                        }
                        Spacer()
                    }
                }
                
                SendMessageView(
                    lastMessage: $lastMessage,
                    sendMessageAction: sendMessage,
                    plusButtonAction: { withAnimation { showButtonsView.toggle() } },
                    cameraButtonAction: { isShowingImagePicker = true },
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
            ImagePicker(didFinishPicking: handleImagePicked)
        }
        .onReceive(keyboardManager.$keyboardHeight) { height in
            globalKeyboardHeight = height
        }
    }
    
    private func sendMessage() {
        let message = ChatMessage(text: lastMessage, isIncoming: false)
        messages.append(message)
        lastMessage = ""
    }
    
    private func handleImagePicked(image: UIImage?) {
        if let image = image {
            let media = ChatMedia(type: .photo(image))
            let message = ChatMessage(media: media, isIncoming: false)
            messages.append(message)
        }
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
