//
//  VideoPlayerView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoData: Data
    
    var body: some View {
        if let url = saveDataToTemporaryFile(data: videoData, fileName: "tempVideo.mp4") {
            VideoThumbnailView(url: url)
                .frame(width: 280, height: 360)
                .background(Color.black)
                .cornerRadius(12)
        } else {
            Text("Unable to load video")
                .foregroundColor(.white)
                .frame(width: 280, height: 360)
                .background(Color.black)
                .cornerRadius(12)
        }
    }
    
    private func saveDataToTemporaryFile(data: Data, fileName: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save video data to temporary file: \(error.localizedDescription)")
            return nil
        }
    }
}

struct VideoThumbnailView: View {
    let url: URL
    
    var body: some View {
        ZStack {
            if let thumbnailImage = generateThumbnail(url: url) {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 360)
                    .clipped()
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 280, height: 360)
            }
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
    }
    
    private func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1.0, preferredTimescale: 60)
        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
