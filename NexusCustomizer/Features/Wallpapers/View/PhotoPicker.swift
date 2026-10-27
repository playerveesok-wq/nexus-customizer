import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    let selectionLimit: Int
    let onFinish: ([PHPickerResult]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        config.selection = .ordered
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onFinish: ([PHPickerResult]) -> Void
        init(onFinish: @escaping ([PHPickerResult]) -> Void) { self.onFinish = onFinish }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onFinish(results)
        }
    }
}