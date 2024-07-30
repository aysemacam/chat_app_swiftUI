//
//  SendMessageView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//
import SwiftUI

struct SendMessageView: View {
    @Binding var lastMessage: String
    var sendMessageAction: () -> Void
    var plusButtonAction: () -> Void
    var cameraButtonAction: () -> Void
    var micButtonAction: (ChatMessage) -> Void
    
    @State private var isPressed = false
    @State private var isCancelled = false
    @State private var recordingDuration: TimeInterval = 0.0
    @State private var timer: Timer? = nil
    @StateObject private var audioRecorderManager = AudioRecorderManager()

    var body: some View {
        VStack {
            HStack {
                Button(action: plusButtonAction) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.top)
                }
                
                TextField("", text: $lastMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                    .padding(.top)
                
                if lastMessage.isEmpty {
                    Button(action: cameraButtonAction) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 21, height: 18)
                            .foregroundColor(.black)
                            .padding(.leading, 5)
                            .padding(.top)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "mic")
                            .resizable()
                            .frame(width: 14, height: 20)
                            .foregroundColor(isPressed ? .red : .black)
                            .padding(.horizontal, 8)
                            .padding(.top)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isPressed {
                                            isPressed = true
                                            isCancelled = false
                                            print("Mikrofona basılı tutmaya başlandı.")
                                            audioRecorderManager.startRecording()
                                            startRecording()
                                        }
                                    }
                                    .onEnded { value in
                                        if value.translation.width < -50 {
                                            isCancelled = true
                                            isPressed = false
                                            print("Record Canceled")
                                            stopRecording(cancelled: true)
                                        } else if isPressed {
                                            isPressed = false
                                            if recordingDuration < 1.0 {
                                                print("Record duration cannot be less than 1 second")
                                                stopRecording(cancelled: true)
                                            } else if !isCancelled {
                                                print("Mikrofondan el çekildi.")
                                                stopRecording(cancelled: false)
                                            }
                                        }
                                    }
                            )
                    }
                } else {
                    Button(action: sendMessageAction) {
                        Text("send")
                            .frame(width: 70, height: 30)
                            .foregroundColor(.black)
                            .padding(.top)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom)
            .background(Color.grayColor)
        }
        .overlay(
            Group {
                if isPressed && !isCancelled {
                    RecordingOverlayView(recordingDuration: recordingDuration, stopRecording: stopRecording(cancelled:))
                }
            }
        )
    }
    
    private func startRecording() {
        recordingDuration = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1.0
        }
    }
    
    private func stopRecording(cancelled: Bool) {
        timer?.invalidate()
        timer = nil
        recordingDuration = 0.0
        if cancelled {
            audioRecorderManager.cancelRecording()
            print("Kayıt iptal edildi, kayıt gönderilmeyecek.")
        } else {
            if let url = audioRecorderManager.stopRecording() {
                print("Kayıt durduruldu.")
                let media = ChatMedia(type: .audio(url))
                let message = ChatMessage(media: media, isIncoming: false)
                micButtonAction(message)
            }
        }
    }
}

