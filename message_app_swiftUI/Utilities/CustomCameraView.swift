//
//  CustomCameraView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @Binding var isPresented: Bool
    var didFinishPicking: (UIImage?, URL?) -> Void
    @StateObject var captureManager = CaptureManager()
    @State private var selectedMode: CameraMode = .photo
    @State private var videoDuration: Int = 0
    @State private var timer: Timer?
    
    enum CameraMode {
        case photo, video
    }
    
    var body: some View {
        ZStack {
            CameraPreview(captureManager: captureManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    if selectedMode == .video {
                        Text("\(formatDuration(videoDuration))")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding()
                    }
                    Spacer()
                    
                    Button(action: {
                        captureManager.toggleFlash()
                    }) {
                        Image(systemName: captureManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                
                CaptureButton(selectedMode: $selectedMode, captureManager: captureManager, didFinishPicking: didFinishPicking, isPresented: $isPresented, videoDuration: $videoDuration, timer: $timer)
                    .padding(.bottom)
                CollectionView(selectedMode: $selectedMode)
            }
        }
        .onAppear {
            captureManager.startSession()
        }
        .onDisappear {
            captureManager.stopSession()
            timer?.invalidate()
        }
        .onChange(of: captureManager.isRecording) { isRecording in
            if isRecording {
                print("Recording started")
            } else {
                print("Recording stopped")
                timer?.invalidate()
                videoDuration = 0
            }
        }
    }
    
    func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var captureManager: CaptureManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        if let previewLayer = captureManager.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CollectionView: View {
    @Binding var selectedMode: CustomCameraView.CameraMode
    
    var body: some View {
        HStack(spacing: 20) {
            Text("Photo")
                .font(.headline)
                .foregroundColor(selectedMode == .photo ? .white : .gray)
                .onTapGesture {
                    selectedMode = .photo
                }
            
            Text("Video")
                .font(.headline)
                .foregroundColor(selectedMode == .video ? .white : .gray)
                .onTapGesture {
                    selectedMode = .video
                }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width, height: 70)
        .background(Color.black.opacity(0.5))
    }
}


struct CaptureButton: View {
    @Binding var selectedMode: CustomCameraView.CameraMode
    @ObservedObject var captureManager: CaptureManager
    var didFinishPicking: (UIImage?, URL?) -> Void
    @Binding var isPresented: Bool
    @Binding var videoDuration: Int
    @Binding var timer: Timer?
    
    var body: some View {
        Button(action: {
            if selectedMode == .photo {
                captureManager.takePhoto { image in
                    didFinishPicking(image, nil)
                    isPresented = false
                }
            } else {
                if captureManager.isRecording {
                    captureManager.stopRecording()
                    timer?.invalidate()
                } else {
                    captureManager.startRecording(durationProgressHandler: { duration in
                        videoDuration = Int(duration)
                    }, completion: { videoURL in
                        didFinishPicking(nil, videoURL)
                        isPresented = false
                    })
                    videoDuration = 0
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        videoDuration += 1
                    }
                }
            }
        }) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 66, height: 66)
                
                if captureManager.isRecording {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                } else {
                    Circle()
                        .fill(selectedMode == .photo ? Color.white : Color.red)
                        .frame(width: 58, height: 58)
                }
            }
        }
    }
}
