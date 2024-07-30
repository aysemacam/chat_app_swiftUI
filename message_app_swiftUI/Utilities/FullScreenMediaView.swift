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
                        .padding(.top)
                        .frame(width: UIScreen.main.bounds.width / 4)
                      
                        Button(action: {
                            print("Edit")
                        }) {
                            Image(systemName: "scribble")
                        }
                        .padding(.top)
                        .frame(width: UIScreen.main.bounds.width / 4)
                        
                        Button(action: {
                            print("Star")
                        }) {
                            Image(systemName: "star")
                        }
                        .padding(.top)
                        .frame(width: UIScreen.main.bounds.width / 4)
                  
                        Button(action: {
                            print("Delete")
                        }) {
                            Image(systemName: "trash")
                        }
                        .padding(.top)
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
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        case .video(let url):
          SimpleVideoPlayerView(videoURL: url)
            
        case .audio:
            Text("Audio content is not supported for full screen view.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
//
//  SimpleVideoPlayerView.swift
//  video_player_app_SwiftUI
//
//  Created by Aysema Çam on 30.07.2024.
//

import SwiftUI
import AVKit

struct SimpleVideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer
    @State private var isPlaying: Bool = true
    @State private var showControls: Bool = false

    init(videoURL: URL) {
        self.videoURL = videoURL
        self._player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CustomVideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                if showControls {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showControls.toggle()
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.7)))
                            }
                            .padding(.trailing)
                        }
                        .padding(.bottom)
                    }
                    .transition(.opacity)
                }
            }
            .onTapGesture {
                withAnimation {
                    showControls.toggle()
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
