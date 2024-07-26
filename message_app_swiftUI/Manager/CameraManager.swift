//
//  CameraManager.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var videoOutput = AVCaptureMovieFileOutput()
    @Published var isFlashOn = false
    @Published var previewLayer = AVCaptureVideoPreviewLayer()
    
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    private var videoCaptureCompletion: ((URL?) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else { return }
        
        session.addInput(videoDeviceInput)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCaptureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startVideoRecording(completion: @escaping (URL?) -> Void) {
        videoCaptureCompletion = completion
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopVideoRecording() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
        }
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
        isFlashOn.toggle()
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletion?(nil)
            return
        }
        photoCaptureCompletion?(image)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            videoCaptureCompletion?(outputFileURL)
        }
    }
}
