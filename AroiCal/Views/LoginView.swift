import SwiftUI
import AVFoundation

// MARK: - Looping background video player (no controls)
struct LoopingVideoPlayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView(player: player)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {}

    class PlayerView: UIView {
        private let playerLayer = AVPlayerLayer()

        init(player: AVPlayer) {
            super.init(frame: .zero)
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(playerLayer)
        }

        required init?(coder: NSCoder) { fatalError() }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }
    }
}

// MARK: - LoginView
struct LoginView: View {
    @Environment(LanguageManager.self) private var lang
    var onGetStarted: () -> Void

    @State private var player: AVPlayer?
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.85

    var body: some View {
        ZStack {
            // Background: looping video or gradient fallback
            if let player {
                LoopingVideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                // Fallback gradient until video is available
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.06, blue: 0.02),
                        Color(red: 0.28, green: 0.12, blue: 0.04),
                        Color(red: 0.50, green: 0.20, blue: 0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            // Dark gradient overlay so text pops
            LinearGradient(
                colors: [
                    Color.black.opacity(0.35),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)

                // App name
                VStack(spacing: 10) {
                    Text("AROI CAL")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .tracking(6)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1, green: 0.72, blue: 0.25),
                                    Color(red: 1, green: 0.42, blue: 0.21)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                        .opacity(titleOpacity)

                    // Thai subtitle (primary)
                    Text("สแกนแคลอรี่ของคุณ")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.90))
                        .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
                        .opacity(subtitleOpacity)

                    // English subtitle (secondary)
                    Text("scan your calories")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .opacity(subtitleOpacity)
                }

                Spacer()

                // Get started button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onGetStarted()
                    }
                } label: {
                    Text(lang.t("Get Started", thai: "เริ่มต้นเลย", japanese: "始めましょう"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1, green: 0.42, blue: 0.21),
                                    Color(red: 1, green: 0.60, blue: 0.08)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: .rect(cornerRadius: 18)
                        )
                        .shadow(color: Color(red: 1, green: 0.42, blue: 0.21).opacity(0.55), radius: 16, x: 0, y: 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
            }
        }
        .onAppear {
            setupPlayer()

            withAnimation(.easeOut(duration: 0.9).delay(0.3)) {
                titleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.9).delay(0.7)) {
                subtitleOpacity = 1
            }
            withAnimation(.spring(duration: 0.6, bounce: 0.25).delay(1.1)) {
                buttonOpacity = 1
                buttonScale = 1.0
            }
        }
        .onDisappear {
            player?.pause()
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "HeroVideo", withExtension: "mp4") else { return }
        let item = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: item)
        avPlayer.isMuted = true
        avPlayer.play()
        self.player = avPlayer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            avPlayer.seek(to: .zero)
            avPlayer.play()
        }
    }
}
