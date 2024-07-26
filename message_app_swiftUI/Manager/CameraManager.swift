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
    @Published var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    private var videoCaptureCompletion: ((URL?) -> Void)
    
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
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCaptureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startVideoRecording(completion: @escaping (URL?) -> Void) {
        guard hasSufficientStorage() else {
            print("Not enough storage to start video recording")
            completion(nil)
            return
        }

        videoCaptureCompletion = completion
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        print("Starting video recording to \(outputURL)")
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopVideoRecording() {
        if videoOutput.isRecording {
            print("Stopping video recording")
            videoOutput.stopRecording()
        } else {
            print("Video output is not recording")
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
    
    private func hasSufficientStorage() -> Bool {
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = attributes[.systemFreeSize] as? Int64 {
            return freeSize > 100 * 1024 * 1024 // Minimum 100 MB boş alan kontrolü
        }
        return false
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
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to \(fileURL)")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
            videoCaptureCompletion?(nil)
        } else {
            print("Finished recording movie to \(outputFileURL)")
            videoCaptureCompletion?(outputFileURL)
        }
    }
}
