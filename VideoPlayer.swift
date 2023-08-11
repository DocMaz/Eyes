import SwiftUI
import AVFoundation

struct VideoPlayerView: UIViewRepresentable {
    var videoName: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        playVideo(in: uiView)
    }

    private func playVideo(in view: UIView) {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            debugPrint("Video not found")
            return
        }

        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
}
