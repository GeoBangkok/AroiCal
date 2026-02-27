import SwiftUI
import AVFoundation
import UIKit

struct CameraProxyView: View {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (Data?) -> Void

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            CameraUnavailablePlaceholder { dismiss() }
            #else
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                CameraCaptureView(onCapture: onCapture)
                    .ignoresSafeArea()
            } else {
                CameraUnavailablePlaceholder { dismiss() }
            }
            #endif
        }
    }
}

struct CameraCaptureView: UIViewControllerRepresentable {
    let onCapture: (Data?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                let data = image.jpegData(compressionQuality: 0.8)
                parent.onCapture(data)
            } else {
                parent.onCapture(nil)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCapture(nil)
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

                    Text("Camera is not available on this device.")
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
