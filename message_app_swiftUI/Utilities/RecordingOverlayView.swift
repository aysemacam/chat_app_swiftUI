//
//  RecordingOverlayView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 30.07.2024.
//

import SwiftUI

struct RecordingOverlayView: View {
    var recordingDuration: TimeInterval
    var stopRecording: (Bool) -> Void
    @State private var micVisible: Bool = true
    @State private var micColor: Color = .gray
    @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Image(systemName: "mic")
                .resizable()
                .foregroundColor(micColor)
                .frame(width: 16, height: 22)
                .opacity(micVisible ? 1 : 0)
                .padding()
                .onAppear {
                    micColor = .gray
                }
                .onReceive(timer) { _ in
                    micVisible.toggle()
                    if recordingDuration > 0 {
                        micColor = .red
                    }
                }
            
            Text(formatTime(recordingDuration))
                .foregroundColor(.black)
                .font(.system(size: 22, weight: .light))

            Text("Slide to cancel")
               
                .foregroundColor(.gray)
                .padding()
                .font(.system(size: 19, weight: .regular))

            
            Image(systemName: "chevron.left")
                .resizable()
                
                .frame(width: 10, height: 17)
                .foregroundColor(.gray)
                
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            stopRecording(true)
                        }
                )
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.grayColor)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
