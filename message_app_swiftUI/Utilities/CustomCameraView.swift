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
    @ObservedObject var cameraManager = CameraManager()
    @State private var selectedMode: CameraMode = .photo
    @State private var videoDuration: Int = 0
    @State private var timer: Timer?
    
    enum CameraMode {
        case photo, video
    }
    
    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
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
                        cameraManager.toggleFlash()
                    }) {
                        Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                
                CaptureButton(selectedMode: $selectedMode, cameraManager: cameraManager, didFinishPicking: didFinishPicking, isPresented: $isPresented, videoDuration: $videoDuration, timer: $timer)
                    .padding(.bottom)
                CollectionView(selectedMode: $selectedMode)
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
            timer?.invalidate()
        }
    }
    
    func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
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
    @ObservedObject var cameraManager: CameraManager
    var didFinishPicking: (UIImage?, URL?) -> Void
    @Binding var isPresented: Bool
    @Binding var videoDuration: Int
    @Binding var timer: Timer?
    
    var body: some View {
        Button(action: {
            if selectedMode == .photo {
                cameraManager.takePhoto { image in
                    didFinishPicking(image, nil)
                    isPresented = false
                }
            } else {
                if cameraManager.videoOutput.isRecording {
                    cameraManager.stopVideoRecording()
                    timer?.invalidate()
                } else {
                    cameraManager.startVideoRecording { videoURL in
                        didFinishPicking(nil, videoURL)
                        isPresented = false
                    }
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
                
                if cameraManager.videoOutput.isRecording {
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

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = cameraManager.previewLayer.session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}
