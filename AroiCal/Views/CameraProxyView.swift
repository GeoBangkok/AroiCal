import SwiftUI
import AVFoundation

struct CameraProxyView: View {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (Data?) -> Void

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            CameraUnavailablePlaceholder { dismiss() }
            #else
            if AVCaptureDevice.default(for: .video) != nil {
                CameraUnavailablePlaceholder { dismiss() }
            } else {
                CameraUnavailablePlaceholder { dismiss() }
            }
            #endif
        }
    }
}

struct CameraUnavailablePlaceholder: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                    }

                    Text("Camera Preview")
                        .font(.title2.weight(.semibold))

                    Text("Install this app on your device\nvia the Rork App to use the camera.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 1, green: 0.42, blue: 0.21), in: .rect(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}
