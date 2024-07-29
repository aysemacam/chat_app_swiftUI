//
//  CaptureManager.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import Foundation
import AVFoundation
import UIKit

final class CaptureManager: NSObject, ObservableObject {
    typealias ProgressHandler = (Double) -> Void
    
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var videoDurationTimer: Timer?
    
    @Published var isRecording = false
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoDurationProgressHandler: ProgressHandler?
    private var photoCompletionHandler: ((UIImage?) -> Void)?
    private var videoCompletionHandler: ((URL?) -> Void)?
    @Published var isFlashOn = false

    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession?.addInput(input)
        } catch {
            print("Error configuring camera input: \(error)")
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            captureSession?.addOutput(photoOutput)
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput {
            captureSession?.addOutput(videoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCompletionHandler = completion
    }
    
    func startRecording(durationProgressHandler: @escaping ProgressHandler, completion: @escaping (URL?) -> Void) {
        guard let videoOutput = videoOutput else { return }
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        self.videoDurationProgressHandler = durationProgressHandler
        self.videoCompletionHandler = completion
        isRecording = true
        
        videoDurationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let duration = self.videoOutput?.recordedDuration.seconds {
                self.videoDurationProgressHandler?(duration)
            }
        }
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
        isRecording = false
        videoDurationTimer?.invalidate()
        videoDurationTimer = nil
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Device has no torch")
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashOn ? .off : .on
            isFlashOn.toggle()
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error)")
        }
    }
}
extension CaptureManager: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            photoCompletionHandler?(nil)
            return
        }
        let image = UIImage(data: data)
        photoCompletionHandler?(image)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        isRecording = false
        videoDurationTimer?.invalidate()
        videoDurationTimer = nil
        videoCompletionHandler?(outputFileURL)
    }
}

