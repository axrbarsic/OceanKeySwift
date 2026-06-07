import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum CapturedMedia {
    case photo(UIImage)
    case video(URL)
}

struct CameraCaptureView: UIViewControllerRepresentable {
    let kind: MediaKind
    let onCapture: (CapturedMedia) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.cameraCaptureMode = kind == .photo ? .photo : .video
        picker.mediaTypes = [kind == .photo ? UTType.image.identifier : UTType.movie.identifier]
        picker.videoQuality = .typeHigh
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(kind: kind, onCapture: onCapture, onCancel: onCancel)
    }
}

extension CameraCaptureView {
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let kind: MediaKind
        private let onCapture: (CapturedMedia) -> Void
        private let onCancel: () -> Void

        init(kind: MediaKind, onCapture: @escaping (CapturedMedia) -> Void, onCancel: @escaping () -> Void) {
            self.kind = kind
            self.onCapture = onCapture
            self.onCancel = onCancel
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            defer { picker.dismiss(animated: true) }

            switch kind {
            case .photo:
                guard let image = info[.originalImage] as? UIImage else {
                    onCancel()
                    return
                }
                onCapture(.photo(image))
            case .video:
                guard let url = info[.mediaURL] as? URL else {
                    onCancel()
                    return
                }
                onCapture(.video(url))
            }
        }
    }
}

