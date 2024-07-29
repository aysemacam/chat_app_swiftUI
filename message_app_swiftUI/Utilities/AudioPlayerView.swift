//
//  AudioPlayerView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import AVFoundation
import Combine

public struct AudioPlayerView: View {
    let url: URL
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var progress: Double = 0.0
    private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().eraseToAnyPublisher()

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        HStack {
            ZStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .clipShape(Circle())
                Image(systemName: "mic.fill")
                    .resizable()
                    .foregroundColor(.darkGray)
                    .frame(width: 10, height: 15)
                    .position(x: 33, y: 33)
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 15) {
                    Button(action: {
                        if player?.isPlaying == true {
                            player?.pause()
                            isPlaying = false
                        } else {
                            player?.currentTime = 0
                            progress = 0
                            currentTime = 0
                            player?.play()
                            isPlaying = true
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 15, height: 16)
                            .foregroundColor(.darkGray)
                    }
                    
                    ProgressView(value: progress, total: playerDuration)
                        .frame(width: 170)
                }
                
                Text(timeString(time: currentTime))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(alignment: .leading)
            }
        }
        .padding(15)
        .background(Color.teaGreen)
        .cornerRadius(12)
        .frame(maxWidth: 270, maxHeight: 70)
        .onReceive(timer) { _ in
            guard let player = player else { return }
            if player.isPlaying {
                currentTime = player.currentTime
                progress = currentTime
            } else if !isPlaying && currentTime == 0 && player.duration > 0 {
                currentTime = player.duration
            }
        }
        .onAppear {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = AVAudioPlayerDelegateHandler(onFinish: {
                    isPlaying = false
                })
                player?.prepareToPlay()
                currentTime = player?.duration ?? 0 // Başlangıçta toplam süreyi göster
                progress = 0 // Progress 0'dan başlasın
            } catch {
                // Handle error
                print("Failed to initialize audio player: \(error.localizedDescription)")
            }
        }
    }
    
    private var playerDuration: Double {
        player?.duration ?? 0
    }
    
    private func timeString(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

class AVAudioPlayerDelegateHandler: NSObject, AVAudioPlayerDelegate {
    var onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}
