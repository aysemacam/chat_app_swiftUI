//
//  AudioPlayerView.swift
//  message_app_swiftUI
//
//  Created by AYsema Çam on 25.07.2024.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let url: URL
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        HStack {
            Button(action: {
                if player?.isPlaying == true {
                    player?.pause()
                } else {
                    player?.play()
                }
            }) {
                Image(systemName: player?.isPlaying == true ? "pause.circle" : "play.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .onAppear {
            do {
                player = try AVAudioPlayer(contentsOf: url)
            } catch {
                // Handle error
            }
        }
    }
}
