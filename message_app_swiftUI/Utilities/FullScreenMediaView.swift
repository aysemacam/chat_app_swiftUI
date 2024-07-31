//
//  FullScreenMediaView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 30.07.2024.
//

import SwiftUI
import AVKit

struct FullScreenMediaView: View {
    let media: ChatMedia
    @Binding var isPresented: Bool
    @State private var controlsVisible: Bool = true
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            getMediaView()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        controlsVisible.toggle()
                    }
                }
            
            if controlsVisible {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "chevron.left")
                                .padding()
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.width / 5)
                        }
                       
                        VStack {
                            Text("You")
                            Text(Date(), style: .date)
                                .font(.subheadline)
                        }
                        .frame(width: UIScreen.main.bounds.width / 2)
                    
                        Button(action: {
                            print("All Medias")
                        }) {
                            Text("All Medias")
                                .foregroundColor(.black)
                        }
                        .frame(width: UIScreen.main.bounds.width / 3)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            print("Save")
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 4)
                      
                        Button(action: {
                            print("Edit")
                        }) {
                            Image(systemName: "scribble")
                        }
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 4)
                        
                        Button(action: {
                            print("Star")
                        }) {
                            Image(systemName: "star")
                        }
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 4)
                  
                        Button(action: {
                            print("Delete")
                        }) {
                            Image(systemName: "trash")
                        }
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 4)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            if case .video(let url) = media.type {
                player = AVPlayer(url: url)
                player?.play()
            }
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    @ViewBuilder
    private func getMediaView() -> some View {
        switch media.type {
        case .photo(let imageData):
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Text("Invalid Image Data")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .video(let url):
            SimpleVideoPlayerView(videoURL: url, controlsVisible: $controlsVisible)
            
        case .audio:
            Text("Audio content is not supported for full screen view.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}




import SwiftUI
import AVKit

struct SimpleVideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer
    @State private var isPlaying = false
    @State private var playbackPosition: Double = 0.0
    @Binding var controlsVisible: Bool

    init(videoURL: URL, controlsVisible: Binding<Bool>) {
        self.videoURL = videoURL
        self._player = State(initialValue: AVPlayer(url: videoURL))
        self._controlsVisible = controlsVisible
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CustomVideoPlayer(player: player)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                        isPlaying = true
                        addPeriodicTimeObserver()
                        addPlayerEndObserver()
                    }
                    .onDisappear {
                        player.pause()
                    }

                if controlsVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            PlayPauseButton(isPlaying: $isPlaying, player: player)
                                .frame(width: 50, height: 50)
                                .background(Color.clear)
                                .clipShape(Circle())
                                .padding()
                            Spacer()
                        }
                        Spacer()
                        ProgressView(value: playbackPosition)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .padding()
                            .background(Color.clear)
                            .padding(.bottom, 70)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onTapGesture {
            withAnimation {
                controlsVisible.toggle()
            }
        }
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.03, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            if let currentItem = player.currentItem {
                playbackPosition = currentItem.currentTime().seconds / currentItem.duration.seconds
            }
        }
    }

    private func addPlayerEndObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            playbackPosition = 0.0
            isPlaying = false
        }
    }
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct PlayPauseButton: View {
    @Binding var isPlaying: Bool
    var player: AVPlayer

    var body: some View {
        Button(action: {
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
        }
    }
}

