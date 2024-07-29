//
//  VideoPlayer.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 29.07.2024.
//

import Combine
import AVFoundation

final class VideoPlayer: ObservableObject {
    @Published var playing = false
    @Published var duration: Double = 0.0
    @Published var secondsLeft: Double = 0.0
    @Published var progress: Double = 0.0

    private let audioSession = AVAudioSession()
    var didPlayTillEnd = PassthroughSubject<Void, Never>()
    
    private var player: AVPlayer?
    private var timeObserver: Any?

    init() {
        try? audioSession.setCategory(.playback)
        try? audioSession.overrideOutputAudioPort(.speaker)
    }

    func play(_ url: URL) {
        setupPlayer(for: url)
        play()
    }

    func pause() {
        player?.pause()
        playing = false
    }

    func togglePlay(_ url: URL) {
        if player?.currentItem?.asset != AVURLAsset(url: url) {
            setupPlayer(for: url)
        }
        if playing { pause() }
        else { play() }
    }

    func seek(to progress: Double) {
        let goalTime = duration * progress
        player?.seek(to: CMTime(seconds: goalTime, preferredTimescale: 10))
        if !playing { play() }
    }

    func reset() {
        if playing {
            pause()
        }
        progress = 0
    }

    private func play() {
        try? audioSession.setActive(true)
        player?.play()
        playing = true
    }

    private func setupPlayer(for url: URL) {
        progress = 0.0
        secondsLeft = 0.0
        duration = 0.0
        NotificationCenter.default.removeObserver(self)
        timeObserver = nil
        player?.replaceCurrentItem(with: nil)

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: nil
        ) { [weak self] _ in
            self?.playing = false
            self?.player?.seek(to: .zero)
            self?.didPlayTillEnd.send()
        }

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 10),
            queue: DispatchQueue.main
        ) { [weak self] time in
            guard let item = self?.player?.currentItem, !item.duration.seconds.isNaN else { return }
            self?.duration = item.duration.seconds
            self?.progress = time.seconds / item.duration.seconds
            self?.secondsLeft = (item.duration - time).seconds.rounded()
        }
    }
}
