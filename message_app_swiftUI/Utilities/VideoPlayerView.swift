//
//  VideoPlayerView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    
    var body: some View {
        ZStack {
            VideoThumbnailView(url: url)
            Image(systemName: "play.circle.fill")
                .resizable()
            
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
        .frame(width: 270, height: 360)
        .background(Color.black)
        .cornerRadius(12)
    }
}

struct VideoThumbnailView: View {
    let url: URL
    
    var body: some View {
        if let thumbnailImage = generateThumbnail(url: url) {
            Image(uiImage: thumbnailImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
    
        } else {
            Rectangle()
                .foregroundColor(.gray)
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
