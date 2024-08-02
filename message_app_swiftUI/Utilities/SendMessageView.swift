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
    @State private var textViewHeight: CGFloat = 30
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button(action: plusButtonAction) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.black.opacity(0.9))
                        
                }
                
                TextView(text: $lastMessage, textViewHeight: $textViewHeight)
                    .frame(height: textViewHeight)
                    .padding(6)
                    .background(Color.clear)
                    .cornerRadius(12)
                   
                  
                
                if lastMessage.isEmpty {
                    Button(action: cameraButtonAction) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 21, height: 18)
                            .foregroundColor(.black)
                            .padding(.leading, 5)
                         
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "mic")
                            .resizable()
                            .frame(width: 14, height: 20)
                            .foregroundColor(isPressed ? .red : .black)
                            .padding(.horizontal, 8)
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
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut)
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
                if let audioData = try? Data(contentsOf: url) {
                    let media = ChatMedia(type: .audio(audioData))
                    let message = ChatMessage(media: media, isIncoming: false)
                    micButtonAction(message)
                } else {
                    print("Audio data conversion failed.")
                }
            }
        }
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textViewHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.backgroundColor = UIColor.white.cgColor
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        TextView.updateHeight(of: uiView, textViewHeight: $textViewHeight)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            TextView.updateHeight(of: textView, textViewHeight: parent.$textViewHeight)
        }
    }

    static func updateHeight(of textView: UITextView, textViewHeight: Binding<CGFloat>) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        var newHeight = size.height
        if (newHeight > 90) {
            newHeight = 90
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        DispatchQueue.main.async {
            textViewHeight.wrappedValue = newHeight
        }
    }
}
